//
//  ChooseStartingArticleVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import UIKit
import WikipediaKit

class ChooseStartingArticleVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Wikipedia language set to english
    let language = WikipediaLanguage("en")
    
    @IBOutlet weak var articlesTableView: UITableView!
    let articleCellIdentifier = "ArticleCell"
    
    var wikiArticles = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WikipediaNetworking.appAuthorEmailForAPI = "maniponce22@gmail.com"
        
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        
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
        performSegue(withIdentifier: "TargetArticleSegueIdentifier", sender: wikiArticle)
    }
    
    // gets 8 random Wiki articles
    func getRandomArticles() {
        Wikipedia.shared.requestRandomArticles(language: self.language, maxCount: 10, imageWidth: 640) {
            (articlePreviews, language, error) in

            guard let articlePreviews = articlePreviews else { return }
            
            self.wikiArticles.removeAll()
            
            for article in articlePreviews {
                let article = Article(title: "\(article.displayTitle)", url: "\(article.url!.lastPathComponent)")
                self.wikiArticles.append(article)
            }
            self.articlesTableView.reloadData()
        }
    }
    
    @IBAction func rerollButtonPressed(_ sender: Any) {
        getRandomArticles()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TargetArticleSegueIdentifier",
            let targetArticleVC = segue.destination as? ChooseTargetArticleVC {
            targetArticleVC.startingArticle = sender as! Article
        }
    }
    
}
