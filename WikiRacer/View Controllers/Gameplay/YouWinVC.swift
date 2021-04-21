//
//  YouWinVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import UIKit
import SwiftySound
import Firebase

class YouWinVC: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numLinksLabel: UILabel!
    @IBOutlet weak var playAgainButton: RoundedButton!
    @IBOutlet weak var leaderboardButton: RoundedButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var earnPointsLabel: UILabel!
    
    let replaySegueIdentifier = "ReplayIdentifier"
    let viewExistingGameIdentifier = "ViewExistingGameIdentifier"
    
    var db: Firestore!
    var game: Game?
    var isMultiplayer: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        // update user stats
        if Auth.auth().currentUser != nil {
            updateStats()
        } else {
            earnPointsLabel.font = self.earnPointsLabel.font.withSize(25)
            earnPointsLabel.text = "Sign up to earn ⚡️"
        }
        
        // resets navigation to this VC
        self.navigationController?.viewControllers = [self]
        let confettiView = SAConfettiView(frame: self.view.bounds)
        self.view.addSubview(confettiView)
        self.view.addSubview(stackView)
        
        if CURRENT_USER!.settings.soundEffectsEnabled {
            
            Sound.play(file: "cork-pop.mp3")
            Sound.play(file: "win.mp3")
        }
        
        confettiView.startConfetti()
        
        let timeDisplayed = game!.elapsedTime
        let minutes = (timeDisplayed % 3600) / 60
        let seconds = (timeDisplayed % 3600) % 60
        timeLabel.text = String(format:"%d:%02d", minutes, seconds)
        numLinksLabel.text = "\(game!.numLinks)"
        
        if isMultiplayer {
            playAgainButton.isHidden = true
            leaderboardButton.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CURRENT_USER!.settings.darkModeEnabled {
            // adopt a light interface style
            overrideUserInterfaceStyle = .dark
        } else {
            // adopt a dark interface style
            overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func playAgainButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: replaySegueIdentifier, sender: nil)
    }
    
    // multiplayer
    @IBAction func leaderboardButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: viewExistingGameIdentifier, sender: game)
    }
    
    // update stats for user
    func updateStats() {
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                var stats = data!["stats"] as! Dictionary<String, Int>
                
                // POINTS
                var totalPoints = 5
                if let currentPoints = data!["points"] as? Int {
                    totalPoints += currentPoints
                }
                docRef.updateData(["points": totalPoints])
                CURRENT_USER!.points = totalPoints
                
                // GAMES WON
                stats["gamesWon"]! += 1
                CURRENT_USER!.stats.gamesWon = stats["gamesWon"]!
                
                // TOTAL GAME TIME
                stats["totalGameTime"]! += self.game!.elapsedTime
                CURRENT_USER!.stats.totalGameTime = stats["totalGameTime"]!
                
                // TOTAL LINKS
                stats["totalNumberOfLinks"]! += self.game!.numLinks
                CURRENT_USER!.stats.totalNumberOfLinks = stats["totalNumberOfLinks"]!
                
                // FASTEST GAME
                let gameTime = self.game!.elapsedTime
                let fastestGame = stats["fastestGame"]!
                
                if gameTime < fastestGame || fastestGame == 0 {
                    stats["fastestGame"]! = gameTime
                    CURRENT_USER!.stats.fastestGame = gameTime
                }
                
                // LEAST NUMBER OF LINKS
                let usedNumLinks = self.game!.numLinks
                let leastNumLinks = stats["leastNumberOfLinks"]!
                
                if usedNumLinks < leastNumLinks || leastNumLinks == 0 {
                    stats["leastNumberOfLinks"]! = usedNumLinks
                    CURRENT_USER!.stats.leastNumberOfLinks = usedNumLinks
                }
                
                docRef.updateData(["stats": stats])
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == replaySegueIdentifier,
           let gameVC = segue.destination as? GameVC {
            gameVC.startingArticle = game!.startingArticle
            gameVC.targetArticle = game!.targetArticle
        } else if segue.identifier == viewExistingGameIdentifier,
                  let viewGameVC = segue.destination as? ViewGameVC {
            viewGameVC.game = sender as? Game
        }
    }
    
}
