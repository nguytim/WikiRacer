//
//  ChooseTargetArticleVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import UIKit
import WikipediaKit
import Firebase
import FirebaseFirestore

class ChooseTargetArticleVC: ChooseStartingArticleVC {
    
    @IBOutlet weak var startingArticleLabel: UILabel!
    
    var db: Firestore!
    var startingArticle: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        startingArticleLabel.text = startingArticle!.title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wikiArticle = wikiArticles[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isMultiplayer != nil {
            performSegue(withIdentifier: viewGameSegueIdentifier, sender: wikiArticle)
        } else {
            performSegue(withIdentifier: "GameSegueIdentifier", sender: wikiArticle)
        }
    }
    
    // get 10 popular articles from wiki in a random day from 1 - 1500
    override func getPopularArticles() {
        rerollButton.isEnabled = false
        let randomDay = Int.random(in: 1..<1500)
        
        let randomDate = Date(timeIntervalSinceNow: TimeInterval(-60 * 60 * 24 * randomDay))
        
        let _ = Wikipedia.shared.requestFeaturedArticles(language: language, date: randomDate) { result in
            switch result {
            case .success(let featuredCollection):
                self.wikiArticles.removeAll()
                
                let popularArticles = featuredCollection.mostReadArticles.shuffled()
                
                var maxArticles = 9
                
                for i in 0...maxArticles {
                    let a = popularArticles[i]
                    if (ProfanityFilter.containsBadWord(a.displayTitle.lowercased()) || a.displayTitle == self.startingArticle?.title) {
                        maxArticles += 1
                    } else {
                        let article = Article(title: "\(a.displayTitle)", lastPathComponentURL: "\(a.url!.lastPathComponent)")
                        self.wikiArticles.append(article)
                    }
                }
                self.articlesTableView.reloadData()
                self.rerollButton.isEnabled = true
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameSegueIdentifier",
           let gameVC = segue.destination as? GameVC {
            gameVC.startingArticle = startingArticle
            gameVC.targetArticle = sender as? Article
        } else if segue.identifier == viewGameSegueIdentifier,
                  let viewGameVC = segue.destination as? ViewGameVC {
            
            let code = getRandomCode()
            let game = Game(startingArticle: startingArticle!, targetArticle: sender as! Article, code: code, gameType: gameType!, leaderboard: [Player]())
            
            viewGameVC.game = game
            // Add a new document in collection "cities"
            db.collection("games").document(code).setData([
                "ownerUID": Auth.auth().currentUser!.uid,
                "gameType": game.gameType!,
                "leaderboard": game.leaderboard!,
                "startingArticleTitle": game.startingArticle.title,
                "startingArticleURL": game.startingArticle.lastPathComponentURL,
                "targetArticleTitle": game.targetArticle.title,
                "targetArticleURL": game.targetArticle.lastPathComponentURL
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.addGameToUsersGames(code: code)
                }
            }
        }
    }
    
    func addGameToUsersGames(code: String) {
        
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        var games: [String] = [String]()
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                games = data!["games"] as! [String]
                games.append(code)
                docRef.updateData(["games": games])
                
            } else {
                games.append(code)
                docRef.updateData(["games": games])
            }
        }
    }
}
