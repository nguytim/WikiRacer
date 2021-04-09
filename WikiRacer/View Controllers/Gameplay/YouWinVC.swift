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
        updateStats()
        
        // resets navigation to this VC
        self.navigationController?.viewControllers = [self]
        let confettiView = SAConfettiView(frame: self.view.bounds)
        self.view.addSubview(confettiView)
        self.view.addSubview(stackView)
        Sound.play(file: "cork-pop.mp3")
        Sound.play(file: "win.mp3")
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
                
                // POINTS
                var totalPoints = 5
                if let currentPoints = data?["points"] as? Int {
                    totalPoints += currentPoints
                }
                docRef.updateData(["points": totalPoints])
                
                // GAMES WON
                var totalGamesWon = 1
                if let gamesWon = data?["gamesWon"] as? Int {
                    totalGamesWon += gamesWon
                }
                docRef.updateData(["gamesWon": totalGamesWon])
                
                // TOTAL GAME TIME
                var totalTime = self.game!.elapsedTime
                if let time = data?["averageGameTime"] as? Int {
                    totalTime += time
                }
                docRef.updateData(["averageGameTime": totalTime])
                
                // TOTAL LINKS
                var totalLinks = self.game!.numLinks
                if let numLinks = data?["averageNumberOfLinks"] as? Int {
                    totalLinks += numLinks
                }
                docRef.updateData(["averageNumberOfLinks": totalLinks])
                
                // FASTEST GAME
                let gameTime = self.game!.elapsedTime
                if let fastestGame = data?["fastestGame"] as? Int {
                    if gameTime < fastestGame || fastestGame == 0 {
                        docRef.updateData(["fastestGame": gameTime])
                    }
                }
                
                // LEAST NUMBER OF LINKS
                let usedNumLinks = self.game!.numLinks
                if let leastNumLinks = data?["leastNumberofLink"] as? Int {
                    if usedNumLinks < leastNumLinks || leastNumLinks == 0 {
                        docRef.updateData(["leastNumberofLink": usedNumLinks])
                    }
                }
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
