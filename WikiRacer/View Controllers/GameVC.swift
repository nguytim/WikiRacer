//
//  GameVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 2/25/21.
//

import UIKit
import WikipediaKit
import WebKit

class GameVC: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    @IBOutlet weak var viewForEmbedingWebView: UIView!
    
    @IBOutlet weak var wikiTitle: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var startingArticleLabel: UILabel!
    @IBOutlet weak var targetArticleLabel: UILabel!
    
    // Wikipedia language set to english
    let language = WikipediaLanguage("en")
    
    let youWinSegueIdentifier = "YouWinSegueIdentifier"
    
    var game: Game?
    
    // game mechanics
    var startingArticle: Article?
    var targetArticle: Article?
    
    var currentArticle: Article?
    var previousArticles = [Article]()
    
    let exStartingArticle = Article(title: "Finding Nemo", lastPathComponentURL: "Finding_Nemo")
    let exTargetArticle = Article(title: "Finding Dory", lastPathComponentURL: "Finding_Dory")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up webview
        webView = WKWebView(frame: viewForEmbedingWebView.bounds, configuration: WKWebViewConfiguration())
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        viewForEmbedingWebView.addSubview(webView)
        
        counterLabel.text = "0"
        
        // TODO: COMMENT THIS OUT AFTER DEMO
        startingArticle = exStartingArticle
        targetArticle = exTargetArticle
        
        currentArticle = startingArticle
        
        startingArticleLabel.text = startingArticle!.title
        targetArticleLabel.text = targetArticle!.title
        print("Starting article: \(startingArticle!.title)")
        print("Target article: \(targetArticle!.title)")
        
        game = Game(startingArticle: startingArticle!.lastPathComponentURL, targetArticle: targetArticle!.lastPathComponentURL)
        
        getArticle(article: startingArticle!.title)
    }
    
    // retrieves the Wiki article and updates the UILabel of the title and UITextview of the description
    func getArticle(article: String) {
        let _ = Wikipedia.shared.requestArticle(language: language, title: article, imageWidth: 640) { result in
            switch result {
            case .success(let article):
                
                // TITLE
                self.wikiTitle.attributedText = self.htmlToString(htmlString: article.displayTitle)
                self.wikiTitle.font = UIFont(name: "Hoefler Text",
                                             size: 20.0)
                
                // LOAD HTML
//                self.webView.loadHTMLString(article.displayText, baseURL: nil)
                
                // OR GO TO URL
                let myRequest = URLRequest(url: article.url!)
                self.webView.load(myRequest)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // handles when a link is clicked on in the WebView
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == WKNavigationType.linkActivated {
                print("link")
                guard let url = navigationAction.request.url else {
                    decisionHandler(WKNavigationActionPolicy.cancel)
                    return
                }
                goToArticle(url: url)
                        
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
            print("no link")
            decisionHandler(WKNavigationActionPolicy.allow)
     }
    
    // go to the Wiki article given its url
    func goToArticle(url: URL) {
        // store the current article in previous articles
        previousArticles.append(currentArticle!)
        
        // get the new article from the last path component of the URL
        let newArticle = url.lastPathComponent
        currentArticle!.lastPathComponentURL = newArticle
        
        backButton.isHidden = false
        
        // navigate to the new Wiki article
        getArticle(article: newArticle)
        updateCounter()
        
        print("Current article: \(currentArticle!.lastPathComponentURL)")
        print("Target article: \(targetArticle!.lastPathComponentURL)")
        
        // user wins the game and the current article matches the target article
        if currentArticle!.lastPathComponentURL == targetArticle!.lastPathComponentURL {
            print("CONGRATULATIONS!! YOU WON!")
            performSegue(withIdentifier: "YouWinSegueIdentifier", sender: nil)
        }
    }
    
    // on button click, user can go back to previous article
    @IBAction func backButtonClicked(_ sender: Any) {
        
        // get the previous article
        currentArticle = previousArticles.popLast()!
        getArticle(article: currentArticle!.title)
        
        updateCounter()
        
        // hide the back button when there are no more previous articles
        if previousArticles.isEmpty {
            backButton.isHidden = true
        }
    }
    
    // update the counter by 1
    func updateCounter() {
        game!.numLinks += 1
        counterLabel.text = String(game!.numLinks)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "YouWinSegueIdentifier",
           let youWinVC = segue.destination as? YouWinVC {
            youWinVC.game = game
        }
    }
    
    // Convert to NSAttributedString
    func htmlToString(htmlString: String) -> NSAttributedString {
        let htmlString = htmlString
        let data = htmlString.data(using: .utf8)!
        let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        return attributedString!
    }
}
