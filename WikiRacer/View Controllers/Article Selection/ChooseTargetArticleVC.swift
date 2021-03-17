//
//  ChooseTargetArticleVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import UIKit
import WikipediaKit

class ChooseTargetArticleVC: ChooseStartingArticleVC {
    
    @IBOutlet weak var startingArticleLabel: UILabel!
    
    var startingArticle: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startingArticleLabel.text = startingArticle!.title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wikiArticle = wikiArticles[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "GameSegueIdentifier", sender: wikiArticle)
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
                    if (a.displayTitle == self.startingArticle?.title) {
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
            gameVC.targetArticle = sender as! Article
        }
    }

}
