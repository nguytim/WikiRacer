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
    @IBOutlet weak var rerollButton: UIButton!
    
    let articleCellIdentifier = "ArticleCell"
    let viewGameSegueIdentifier = "ViewGameSegueIdentifier"
    
    var wikiArticles = [Article]()
    var isMultiplayer: Bool?
    var gameType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WikipediaNetworking.appAuthorEmailForAPI = "maniponce22@gmail.com"
        
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        
        rerollButton.setTitleColor(.systemGray, for: .disabled)
        
        getPopularArticles()
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
        performSegue(withIdentifier: "TargetArticleSegueIdentifier", sender: wikiArticle)
    }
    
    // get 10 popular articles from wiki in a random day from 1 - 1500
    func getPopularArticles() {
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
                    if (ProfanityFilter.containsBadWord(a.displayTitle.lowercased())) {
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
    
    // gets 10 random Wiki articles
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
        getPopularArticles()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TargetArticleSegueIdentifier",
            let targetArticleVC = segue.destination as? ChooseTargetArticleVC {
            targetArticleVC.startingArticle = sender as? Article
            if isMultiplayer != nil {
                targetArticleVC.isMultiplayer = isMultiplayer
                targetArticleVC.gameType = gameType
            }
        }
    }
    
}
