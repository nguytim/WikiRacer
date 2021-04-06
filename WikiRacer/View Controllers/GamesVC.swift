//
//  GamesVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/25/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

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
        games = [Game]()
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
//        cell.layer.cornerRadius = 8
//        cell.layer.masksToBounds = true
//
//        cell.layer.masksToBounds = false
////        cell.layer.shadowOffset = CGSizeMake(0, 0)
////        cell.layer.shadowColor = UIColor.blackColor().CGColor
//        cell.layer.shadowOpacity = 0.23
//        cell.layer.shadowRadius = 4
        
        // initialization
        cell.startingArticleLabel.text = game.startingArticle.title
        cell.targetArticleLabel.text = game.targetArticle.title
        
        if game.hasPlayed! {
            cell.gameStatusLabel.text = "Check results"
            cell.backgroundColor = UIColor.init(named: "MainLimeGreenColor")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: self.viewExistingGameIdentifier, sender: game)
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        let index = indexPath.row
//        let game = games[index]
//        
//        if editingStyle == .delete {
//            
//            games.remove(at: index)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
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
                    
                    var hasPlayed = false
                    
                    if !leaderboardData.isEmpty {
                        for i in 0...leaderboardData.count - 1 {
                            let player = leaderboardData[i] as! [String: Any]
                            leaderboard.append(
                                Player(uid: player["uid"] as! String,
                                       name: player["name"] as! String,
                                       time: player["time"] as! String,
                                       numLinks: player["links"] as! Int)
                            )
                            hasPlayed = player["uid"] as? String == Auth.auth().currentUser?.uid
                        }
                    }
                    
                    let startingArticle = Article(title: startingArticleTitle, lastPathComponentURL: startingArticleURL)
                    let targetArticle = Article(title: targetArticleTitle, lastPathComponentURL: targetArticleURL)
                    
                    let game = Game(startingArticle: startingArticle, targetArticle: targetArticle, code: gameID, gameType: gameType, leaderboard: leaderboard)
                    
                    game.hasPlayed = hasPlayed
                    
                    self.games.append(game)
                    self.gamesTableView.reloadData()
                } else {
                    print("CODE IS NOT VALID")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        
        let verticalPadding: CGFloat = 12

        let maskLayer = CALayer()
        maskLayer.cornerRadius = 15   //if you want round edges
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer

        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == viewExistingGameIdentifier,
                  let viewGameVC = segue.destination as? ViewGameVC {
            viewGameVC.game = sender as? Game
            viewGameVC.backViewController = self
        }
    }

}
