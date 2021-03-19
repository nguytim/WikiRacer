//
//  GameTypeVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/16/21.
//

import UIKit
import Firebase

class GameTypeVC: UIViewController {
    
    var db: Firestore?
    
    @IBOutlet weak var normalButton: RoundedButton!
    @IBOutlet weak var timeTrialButton: RoundedButton!
    @IBOutlet weak var leastLinksButton: RoundedButton!
    @IBOutlet weak var customButton: RoundedButton!
    @IBOutlet weak var goBackButton: RoundedButton!
    @IBOutlet weak var searchForGameBlock: UIStackView!
    @IBOutlet weak var codeTextField: UITextField!
    
    var isMultiplayer: Bool = false
    var isTimeTrial: Bool = true
    
    let selectArticlesIdentifier = "SelectArticlesSegueIdentifier"
    let customArticleIdentifier = "CustomGameSegueIdentifier"
    let viewExistingGameIdentifier = "ViewExistingGameIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isMultiplayer {
            normalButton.isHidden = true
            customButton.isHidden = true
            timeTrialButton.isHidden = false
            leastLinksButton.isHidden = false
            searchForGameBlock.isHidden = false
            
            // [START setup]
            let settings = FirestoreSettings()
            
            Firestore.firestore().settings = settings
            // [END setup]
            db = Firestore.firestore()
        }
    }
    
    @IBAction func normalButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: selectArticlesIdentifier, sender: nil)
    }
    
    @IBAction func customButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: customArticleIdentifier, sender: isMultiplayer)
    }
    
    @IBAction func timeTrialButtonPressed(_ sender: Any) {
        isTimeTrial = true
        multiplayerModesToGameModes()
    }
    
    @IBAction func leastLinksButtonPressed(_ sender: Any) {
        isTimeTrial = false
        multiplayerModesToGameModes()
    }
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        gameModesToMultiplayerModes()
    }
    
    @IBAction func codeEnterButtonPressed(_ sender: Any) {
        let code = codeTextField.text!
        print("Code ENTERED \(code)")
        if (code == "") {
            print("CODE CANNOT BE EMPTY")
        } else {
            let docRef = db!.collection("games").document(code)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    let gameType = data!["gameType"] as! String
                    let startingArticleTitle = data!["startingArticle"] as! String
                    let targetArticleTitle = data!["targetArticle"] as! String
                    let leaderboardData = data!["leaderboard"] as! [Any]
                    
                    var leaderboard = [Player]()
                    
                    for i in 0...leaderboardData.count - 1 {
                        let player = leaderboardData[i] as! [String: Any]
                        leaderboard.append(
                            Player(name: player["name"] as! String,
                                   time: player["time"] as! String,
                                   numLinks: player["links"] as! Int)
                        )
                    }
                    
                    let startingArticle = Article(title: startingArticleTitle, lastPathComponentURL: startingArticleTitle)
                    let targetArticle = Article(title: targetArticleTitle, lastPathComponentURL: targetArticleTitle)
                    
                    let game = Game(startingArticle: startingArticle, targetArticle: targetArticle)
                    game.gameType = gameType
                    game.leaderboard = leaderboard
                    game.code = code
                    
                    self.performSegue(withIdentifier: self.viewExistingGameIdentifier, sender: game)
                } else {
                    print("CODE IS NOT VALID")
                }
            }
        }
    }
    
    func multiplayerModesToGameModes() {
        timeTrialButton.isHidden = true
        leastLinksButton.isHidden = true
        normalButton.isHidden = false
        customButton.isHidden = false
        goBackButton.isHidden = false
    }
    
    func gameModesToMultiplayerModes() {
        timeTrialButton.isHidden = false
        leastLinksButton.isHidden = false
        normalButton.isHidden = true
        customButton.isHidden = true
        goBackButton.isHidden = true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == selectArticlesIdentifier,
           let chooseArticleVC = segue.destination as? ChooseStartingArticleVC {
            // CHECK MULTIPLAYER and WHICH TRAIL
            
        } else if segue.identifier == customArticleIdentifier {
            // CHECK MULTIPLAYER AND WHICH TRIAL
        } else if segue.identifier == viewExistingGameIdentifier,
                  let viewGameVC = segue.destination as? ViewGameVC {
            viewGameVC.game = sender as? Game
        }
    }
    
}
