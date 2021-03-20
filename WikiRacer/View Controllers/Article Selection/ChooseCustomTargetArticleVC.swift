//
//  ChooseCustomTargetArticleVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/16/21.
//

import UIKit
import Firebase

class ChooseCustomTargetArticleVC: ChooseCustomStartingArticleVC {
    
    var db: Firestore!
    
    @IBOutlet weak var startingArticleLabel: UILabel!
    
    let gameplayIdentifier = "GameplaySegueIdentifier"
    
    var startingArticle: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        startingArticleLabel.text = startingArticle?.title
    }
    
    override func goToGame(article: Article) {
        if article.title.lowercased() == startingArticle!.title.lowercased() {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "You cannot choose the same article!"
        } else if isMultiplayer != nil {
            performSegue(withIdentifier: viewGameSegueIdentifier, sender: article)
        } else {
            performSegue(withIdentifier: gameplayIdentifier, sender: article)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gameplayIdentifier,
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
                }
            }
        }
    }

}
