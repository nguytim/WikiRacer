//
//  YouWinVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import UIKit
import SwiftySound
import Firebase
import FirebaseFirestore

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
        
        // add game points for user
        addPointsForUser()
        
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
    
    func addPointsForUser() {
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                var pointsEarned = 5
                if let currentPoints = data?["points"] as? Int {
                    pointsEarned += currentPoints
                }
                docRef.updateData(["points": pointsEarned])
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
