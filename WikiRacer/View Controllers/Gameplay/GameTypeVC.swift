//
//  GameTypeVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/16/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class GameTypeVC: UIViewController {
    
    var db: Firestore?
    
    @IBOutlet weak var normalButton: RoundedButton!
    @IBOutlet weak var timeTrialButton: RoundedButton!
    @IBOutlet weak var leastLinksButton: RoundedButton!
    @IBOutlet weak var customButton: RoundedButton!
    @IBOutlet weak var goBackButton: RoundedButton!
    @IBOutlet weak var searchForGameBlock: UIStackView!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var joinGameButton: RoundedButton!
    @IBOutlet weak var newGameButton: RoundedButton!
    @IBOutlet weak var goBackNewJoinGameButton: RoundedButton!
    
    var isMultiplayer: Bool = false
    var gameType: String = ""
    
    let selectArticlesIdentifier = "SelectArticlesSegueIdentifier"
    let customArticleIdentifier = "CustomGameSegueIdentifier"
    let viewExistingGameIdentifier = "ViewExistingGameIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isMultiplayer {
            newGameButton.isHidden = false
            joinGameButton.isHidden = false
            normalButton.isHidden = true
            customButton.isHidden = true
            timeTrialButton.isHidden = true
            leastLinksButton.isHidden = true
            searchForGameBlock.isHidden = true
            goBackNewJoinGameButton.isHidden = true
            
            
            // [START setup]
            let settings = FirestoreSettings()
            
            Firestore.firestore().settings = settings
            // [END setup]
            db = Firestore.firestore()
        } else {
            newGameButton.isHidden = true
            joinGameButton.isHidden = true
            goBackNewJoinGameButton.isHidden = true
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
    
    @IBAction func normalButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: selectArticlesIdentifier, sender: nil)
    }
    
    @IBAction func joinGameButtonPressed(_ sender: Any) {
        newGameButton.isHidden = true
        joinGameButton.isHidden = true
        normalButton.isHidden = true
        customButton.isHidden = true
        timeTrialButton.isHidden = true
        leastLinksButton.isHidden = true
        searchForGameBlock.isHidden = false
        goBackNewJoinGameButton.isHidden = false
    }
    
    @IBAction func newGameButtonPressed(_ sender: Any) {
        newGameButton.isHidden = true
        joinGameButton.isHidden = true
        normalButton.isHidden = true
        customButton.isHidden = true
        timeTrialButton.isHidden = false
        leastLinksButton.isHidden = false
        searchForGameBlock.isHidden = true
        goBackNewJoinGameButton.isHidden = false
    }
    
    @IBAction func customButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: customArticleIdentifier, sender: isMultiplayer)
    }
    
    @IBAction func timeTrialButtonPressed(_ sender: Any) {
        gameType = "Time Trial"
        multiplayerModesToGameModes()
    }
    
    @IBAction func leastLinksButtonPressed(_ sender: Any) {
        gameType = "Least Links"
        multiplayerModesToGameModes()
    }
    
    @IBAction func goBackNewJoinGameButtonPressed(_ sender: Any) {
        goBackNewJoinGameButton.isHidden = true
        newGameButton.isHidden = false
        joinGameButton.isHidden = false
        normalButton.isHidden = true
        customButton.isHidden = true
        timeTrialButton.isHidden = true
        leastLinksButton.isHidden = true
        searchForGameBlock.isHidden = true
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
                    let leaderboardData = data!["leaderboard"] as! [Any]
                    let startingArticleTitle = data!["startingArticleTitle"] as! String
                    let startingArticleURL = data!["startingArticleURL"] as! String
                    let targetArticleTitle = data!["targetArticleTitle"] as! String
                    let targetArticleURL = data!["targetArticleURL"] as! String
                    
                    var leaderboard = [Player]()
                    
                    if !leaderboardData.isEmpty {
                        for i in 0...leaderboardData.count - 1 {
                            let player = leaderboardData[i] as! [String: Any]
                            leaderboard.append(
                                Player(uid: player["uid"] as! String,
                                       name: player["name"] as! String,
                                       time: player["time"] as! Int,
                                       numLinks: player["links"] as! Int)
                            )
                        }
                    }
                    
                    let startingArticle = Article(title: startingArticleTitle, lastPathComponentURL: startingArticleURL)
                    let targetArticle = Article(title: targetArticleTitle, lastPathComponentURL: targetArticleURL)
                    
                    let game = Game(startingArticle: startingArticle, targetArticle: targetArticle, code: code, gameType: gameType, leaderboard: leaderboard)
                    
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
        goBackNewJoinGameButton.isHidden = true
    }
    
    func gameModesToMultiplayerModes() {
        timeTrialButton.isHidden = false
        leastLinksButton.isHidden = false
        normalButton.isHidden = true
        customButton.isHidden = true
        goBackButton.isHidden = true
        goBackNewJoinGameButton.isHidden = false
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == selectArticlesIdentifier,
           let chooseArticleVC = segue.destination as? ChooseStartingArticleVC {
            
            if isMultiplayer {
                chooseArticleVC.isMultiplayer = true
                chooseArticleVC.gameType = gameType
            }
        } else if segue.identifier == customArticleIdentifier,
                  let chooseArticleVC = segue.destination as? ChooseCustomStartingArticleVC {
            
            if isMultiplayer {
                chooseArticleVC.isMultiplayer = true
                chooseArticleVC.gameType = gameType
            }
        } else if segue.identifier == viewExistingGameIdentifier,
                  let viewGameVC = segue.destination as? ViewGameVC {
            viewGameVC.game = sender as? Game
        }
    }
    
}
