//
//  ChooseCustomTargetArticleVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/16/21.
//

import UIKit

class ChooseCustomTargetArticleVC: ChooseCustomStartingArticleVC {
    
    @IBOutlet weak var startingArticleLabel: UILabel!
    
    let gameplayIdentifier = "GameplaySegueIdentifier"
    
    var startingArticle: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startingArticleLabel.text = startingArticle?.title
    }
    
    override func goToGame(article: Article) {
        performSegue(withIdentifier: gameplayIdentifier, sender: article)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gameplayIdentifier,
            let gameVC = segue.destination as? GameVC {
            gameVC.startingArticle = startingArticle
            gameVC.targetArticle = sender as! Article
        }
    }

}
