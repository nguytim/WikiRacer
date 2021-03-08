//
//  ChooseTargetArticleVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import UIKit
import WikipediaKit

public class Article {
    var title: String
    var lastPathComponentURL: String
    
    init(title: String, lastPathComponentURL: String) {
        self.title = title
        self.lastPathComponentURL = lastPathComponentURL
    }
}

class ChooseTargetArticleVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Wikipedia language set to english
    let language = WikipediaLanguage("en")
    
    @IBOutlet weak var articlesTableView: UITableView!
    @IBOutlet weak var startingArticleLabel: UILabel!
    
    let articleCellIdentifier = "ArticleCell"
    
    var wikiArticles = [Article]()
    var startingArticle: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WikipediaNetworking.appAuthorEmailForAPI = "maniponce22@gmail.com"
        
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        
        startingArticleLabel.text = startingArticle!.title
        
        getRandomArticles()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wikiArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: articleCellIdentifier, for: indexPath as IndexPath)
        let wikiArticle = wikiArticles[indexPath.row].title
        cell.textLabel!.text = "\(wikiArticle)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wikiArticle = wikiArticles[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "GameSegueIdentifier", sender: wikiArticle)
    }
    
    // gets 8 random Wiki articles
    func getRandomArticles() {
        Wikipedia.shared.requestRandomArticles(language: self.language, maxCount: 10, imageWidth: 640) {
            (articlePreviews, language, error) in

            guard let articlePreviews = articlePreviews else { return }
            
            self.wikiArticles.removeAll()
            
            for article in articlePreviews {
                let article = Article(title: "\(article.displayTitle)", lastPathComponentURL: "\(article.url!.lastPathComponent)")
                self.wikiArticles.append(article)
            }
            self.articlesTableView.reloadData()
        }
    }
    
    @IBAction func rerollButtonPressed(_ sender: Any) {
        getRandomArticles()
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
