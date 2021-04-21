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
    @IBOutlet weak var titleLabel: UILabel!
    
    let articleCellIdentifier = "ArticleCell"
    let viewGameSegueIdentifier = "ViewGameSegueIdentifier"
    
    var wikiArticles = [Article]()
    var isMultiplayer: Bool?
    var gameType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isMultiplayer != nil {
            titleLabel.text = "Multiplayer"
        }
        
        WikipediaNetworking.appAuthorEmailForAPI = "maniponce22@gmail.com"
        
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        
        rerollButton.setTitleColor(.systemGray, for: .disabled)
        
        getPopularArticles()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wikiArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: articleCellIdentifier, for: indexPath as IndexPath)
        let wikiArticle = wikiArticles[indexPath.row].title
        cell.textLabel!.text = "\(wikiArticle)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let verticalPadding: CGFloat = 12

        let maskLayer = CALayer()
        maskLayer.cornerRadius = 20   //if you want round edges
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wikiArticle = wikiArticles[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "TargetArticleSegueIdentifier", sender: wikiArticle)
    }
    
    // get 10 popular articles from wiki in a random day from 1 - 1500
    func getPopularArticles() {
        wikiArticles.removeAll()
        articlesTableView.reloadData()
        self.showSpinner(onView: self.view)
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
                self.articlesTableView.reloadWithAnimation()
                self.rerollButton.isEnabled = true
                self.removeSpinner()
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
            
            self.articlesTableView.reloadWithAnimation()
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

extension UITableView {

    func reloadWithAnimation() {
        self.reloadData()
        let tableViewHeight = self.bounds.size.height
        let cells = self.visibleCells
        var delayCounter = 0
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        for cell in cells {
            UIView.animate(withDuration: 1.0, delay: 0.08 * Double(delayCounter),usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
}
