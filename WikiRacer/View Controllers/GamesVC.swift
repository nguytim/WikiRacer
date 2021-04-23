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

protocol RefreshGames {
    func refreshGames()
}

class GameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var startingArticleLabel: UILabel!
    @IBOutlet weak var targetArticleLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    
}

class GamesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, RefreshGames {
    
    @IBOutlet weak var gamesTableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    var games: [Game] = [Game]()
    var gameIDs: [String] = [String]()
    var db: Firestore!
    
    let gameCellIdentifier: String = "GameTableViewCellIdentifier"
    let viewExistingGameIdentifier: String = "ViewGameSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        gamesTableView.dataSource = self
        gamesTableView.delegate = self
        
        getCurrentUsersGames()
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
    
    func refreshGames() {
        refreshButton.isEnabled = false
        games = [Game]()
        getCurrentUsersGames()
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        refreshGames()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(games.count == 0 && Auth.auth().currentUser == nil) {
            print("Inside count = 0 and nill auth")
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 350, height: 350))
            messageLabel.text = "Sign up or log in to to take part of Multiplayer mode and keep track of your races against others"
            messageLabel.center = view.center
            messageLabel.textAlignment = .center
            messageLabel.textColor = UIColor(named: "MainAquaColor")
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "Righteous", size: 20)
            messageLabel.sizeToFit()
            
            self.view.addSubview(messageLabel)
        }
        
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
        
        let hasPlayed = game.hasPlayed!
        
        if hasPlayed {
            cell.gameStatusLabel.text = "Check results"
            cell.backgroundColor = UIColor.init(named: "MainLimeGreenColor")
        } else {
            cell.gameStatusLabel.text = "In Progress"
            cell.backgroundColor = UIColor.init(named: "MainYellowColor")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = games[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: self.viewExistingGameIdentifier, sender: game)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let game = games[index]
        
        if editingStyle == .delete {
            // if OWNER of the game, prompt
            if game.ownerUID == Auth.auth().currentUser!.uid {
                
                let deleteAlert = UIAlertController(title: "Delete game", message: "Are you sure you want to delete this game? This action cannot be undone.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
                    deleteAlert.dismiss(animated: true, completion: nil)
                }
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                    
                    self.games.remove(at: index)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    // DELETE GAME CODE IN USER'S FIREBASE
                    let userRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)
                    userRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            
                            if var games = data!["games"] as? [String] {
                                games.remove(at: games.firstIndex(of: game.code!)!)
                                userRef.updateData(["games": games])
                            }
                            
                            if var gamesOwned = data!["gamesOwned"] as? [String] {
                                gamesOwned.remove(at: gamesOwned.firstIndex(of: game.code!)!)
                                userRef.updateData(["gamesOwned": gamesOwned])
                            }
                            
                        }
                    }
                    
                    // DELETE GAME IN FIREBASE
                    self.db.collection("games").document(game.code!).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                }
                
                deleteAlert.addAction(cancelAction)
                deleteAlert.addAction(deleteAction)
                
                self.present(deleteAlert, animated: true, completion: nil)
            } else {
                // if regular user
                games.remove(at: index)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // DELETE GAME CODE IN USER'S FIREBASE
                let userRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)
                userRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        var games = data!["games"] as! [String]
                        games.remove(at: games.firstIndex(of: game.code!)!)
                        userRef.updateData(["games": games])
                    }
                }
            }
        }
    }
    
    func getCurrentUsersGames() {
        if Auth.auth().currentUser != nil {
            let docRef = db!.collection("users").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    if (data?["games"] != nil && !(data?["games"] as! [String]).isEmpty) {
                        self.gameIDs = data!["games"] as! [String]
                        self.getGames()
                    } else {
                        self.refreshButton.isEnabled = true
                        self.gamesTableView.reloadData()
                    }
                }
            }
        } else {
            self.refreshButton.isEnabled = true
        }
    }
    
    func getGames() {
        for gameID in gameIDs {
            let docRef = db!.collection("games").document(gameID)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    let gameType = data!["gameType"] as! String
                    let ownerUID = data!["ownerUID"] as! String
                    let leaderboardData = data!["leaderboard"] as! [Any]
                    let startingArticleTitle = data!["startingArticleTitle"] as! String
                    let startingArticleURL = data!["startingArticleURL"] as! String
                    let targetArticleTitle = data!["targetArticleTitle"] as! String
                    let targetArticleURL = data!["targetArticleURL"] as! String
                    
                    var leaderboard = [Player]()
                    
                    var hasPlayed = false
                    let isTimeTrial = gameType == "Time Trial" ? true : false
                    
                    if !leaderboardData.isEmpty {
                        for i in 0...leaderboardData.count - 1 {
                            let playerData = leaderboardData[i] as! [String: Any]
                            let player = Player(uid: playerData["uid"] as! String,
                                                name: playerData["name"] as! String,
                                                time: playerData["time"] as! Int,
                                                numLinks: playerData["links"] as! Int)
                            player.timeTrial = isTimeTrial
                            leaderboard.append(player)
                            
                            if playerData["uid"] as? String == Auth.auth().currentUser?.uid {
                                hasPlayed = true
                            }
                        }
                    }
                    
                    leaderboard.sort(by: <)
                    
                    let startingArticle = Article(title: startingArticleTitle, lastPathComponentURL: startingArticleURL)
                    let targetArticle = Article(title: targetArticleTitle, lastPathComponentURL: targetArticleURL)
                    
                    let game = Game(startingArticle: startingArticle, targetArticle: targetArticle, ownerUID: ownerUID, code: gameID, gameType: gameType, leaderboard: leaderboard)
                    
                    game.hasPlayed = hasPlayed
                    self.games.append(game)
                    self.games.sort(by: <)
                    self.gamesTableView.reloadData()
                    self.refreshButton.isEnabled = true
                } else {
                    print("CODE IS NOT VALID")
                    
                    // DELETE GAME CODE IN USER'S FIREBASE
                    let userRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)
                    userRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            var games = data!["games"] as! [String]
                            if games.contains(gameID) {
                                games.remove(at: games.firstIndex(of: gameID)!)
                                userRef.updateData(["games": games])
                            }
                        }
                    }
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
