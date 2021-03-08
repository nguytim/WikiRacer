//
//  WikipediaTool.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import WikipediaKit

class WikipediaTool {
    
    // Wikipedia language set to english
    let language = WikipediaLanguage("en")
    
    init() {
        WikipediaNetworking.appAuthorEmailForAPI = "maniponce22@gmail.com"
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
                print(article.displayTitle)
                print(article.displayText)
                
            case .failure(let error):
              print(error)
            }
        }
    }
}
