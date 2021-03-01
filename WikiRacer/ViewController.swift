//
//  ViewController.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 2/25/21.
//

import UIKit
import WikipediaKit

class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var wikiTitle: UILabel!
    @IBOutlet weak var wikiDescription: UITextView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    // Wikipedia language set to english
    let language = WikipediaLanguage("en")
    
    // game mechanics
    var linkCounter = 0
    var previousArticles = [String]()
    var currentArticle = "Attack on Titan"
    let targetArticle = "Eren_Yeager"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wikiDescription.delegate = self
        counterLabel.text = "0"
        
        WikipediaNetworking.appAuthorEmailForAPI = "maniponce22@gmail.com"
        
        getArticle(article: currentArticle)
    }
    
    // gets one random Wiki article
    func getRandomArticle() {
        Wikipedia.shared.requestSingleRandomArticle(language: self.language, maxCount: 8, imageWidth: 640) {
            (article, language, error) in

            guard let article = article else { return }

            print(article.displayTitle)
        }
    }
    
    // gets 8 random Wiki articles
    func getRandomArticles() {
        Wikipedia.shared.requestRandomArticles(language: self.language, maxCount: 8, imageWidth: 640) {
            (articlePreviews, language, error) in

            guard let articlePreviews = articlePreviews else { return }

            for article in articlePreviews {
                print(article.displayTitle)
            }
        }
    }
    
    // gets a list of Wikipedia article searches
    func getArticleSearches(queryText: String) {
        let _ = Wikipedia.shared.requestOptimizedSearchResults(language: language, term: queryText) { (searchResults, error) in

            guard error == nil else { return }
            guard let searchResults = searchResults else { return }

            for articlePreview in searchResults.items {
                print(articlePreview.displayTitle)
            }
        }
    }
    
    // retrieves the Wiki article and updates the UILabel of the title and UITextview of the description
    func getArticle(article: String) {
        let _ = Wikipedia.shared.requestArticle(language: language, title: article, imageWidth: 640) { result in
            switch result {
            case .success(let article):
                self.wikiTitle.attributedText = self.htmlToString(htmlString: article.displayTitle)
                self.wikiTitle.font = UIFont(name: "Hoefler Text",
                                             size: 20.0)
                self.wikiDescription.attributedText = self.htmlToString(htmlString: article.displayText)
                
                // TODO: This only needs to be set to false one time until the article gets generated
                self.wikiTitle.isHidden = false
                self.wikiDescription.isHidden = false
                
            case .failure(let error):
              print(error)
            }
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
    
    // when the user clicks on a URL, the article will change
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        // store the current article in previous articles
        previousArticles.append(currentArticle)
        
        // get the new article from the last path component of the URL
        let newArticle = URL.lastPathComponent
        currentArticle = newArticle

        backButton.isHidden = false
        
        // navigate to the new Wiki article
        getArticle(article: newArticle)
        updateCounter()
        
        // user wins the game and the current article matches the target article
        if currentArticle == targetArticle {
            print("CONGRATULATIONS!! YOU WON!")
        }
        
        return false // don't navigate to the URL on a web browser
    }
    
    // on button click, user can go back to previous article
    @IBAction func backButtonClicked(_ sender: Any) {
        
        // get the previous article
        currentArticle = previousArticles.popLast()!
        getArticle(article: currentArticle)
        
        updateCounter()
        
        // hide the back button when there are no more previous articles
        if previousArticles.isEmpty {
            backButton.isHidden = true
        }
    }
    
    // update the counter by 1
    func updateCounter() {
        linkCounter += 1
        counterLabel.text = String(linkCounter)
    }
}

