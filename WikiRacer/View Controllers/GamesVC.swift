//
//  GamesVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/25/21.
//

import UIKit
import Firebase
import FirebaseAuth

class GameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var startingArticleLabel: UILabel!
    @IBOutlet weak var targetArticleLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    
}

class GamesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var gamesTableView: UITableView!
    
    var games: [Game] = [Game]()
    var gameIDs: [String] = [String]()
    var db: Firestore!
    
    let gameCellIdentifier: String = "GameTableViewCellIdentifier"
    let viewExistingGameIdentifier: String = "ViewGameSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        gamesTableView.dataSource = self
        gamesTableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getCurrentUsersGames()
        
        // set if game has already been played and set the game.played = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: gameCellIdentifier, for: indexPath as IndexPath) as! GameTableViewCell
        
        let game = games[indexPath.row]
        
        // style
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true

        cell.layer.masksToBounds = false
//        cell.layer.shadowOffset = CGSizeMake(0, 0)
//        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowOpacity = 0.23
        cell.layer.shadowRadius = 4
        
        // initialization
        cell.startingArticleLabel.text = game.startingArticle.title
        cell.targetArticleLabel.text = game.targetArticle.title
//        cell.gameStatusLabel = "Check results"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[indexPath.row]
        self.performSegue(withIdentifier: self.viewExistingGameIdentifier, sender: game)
    }
    
    func getCurrentUsersGames() {
        let docRef = db!.collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if (data?["games"] != nil) {
                    self.gameIDs = data!["games"] as! [String]
                    self.getGames()
                }
            }
        }
    }
    
    func getGames() {
        for gameID in gameIDs {
            let docRef = db!.collection("games").document(gameID)
            
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
                                       time: player["time"] as! String,
                                       numLinks: player["links"] as! Int)
                            )
                        }
                    }
                    
                    let startingArticle = Article(title: startingArticleTitle, lastPathComponentURL: startingArticleURL)
                    let targetArticle = Article(title: targetArticleTitle, lastPathComponentURL: targetArticleURL)
                    
                    let game = Game(startingArticle: startingArticle, targetArticle: targetArticle, code: gameID, gameType: gameType, leaderboard: leaderboard)
                    
                    self.games.append(game)
                    self.gamesTableView.reloadData()
                } else {
                    print("CODE IS NOT VALID")
                }
            }
        }
    }
    
//    func checkIfUserHasPlayedAlready() {
//        for game in games {
//            for player in game.leaderboard! {
//                if player.uid == uid {
////                    game.played = true
//                    break
//                }
//            }
//        }
//    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == viewExistingGameIdentifier,
                  let viewGameVC = segue.destination as? ViewGameVC {
            viewGameVC.game = sender as? Game
        }
    }

}
