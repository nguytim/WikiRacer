//
//  ViewController.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 2/25/21.
//

import UIKit
import WikipediaKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        WikipediaNetworking.appAuthorEmailForAPI = "maniponce22@gmail.com"
        
        let language = WikipediaLanguage("en")

//        let _ = Wikipedia.shared.requestOptimizedSearchResults(language: language, term: "Serial Experiments Lain") { (searchResults, error) in
//
//            guard error == nil else { return }
//            guard let searchResults = searchResults else { return }
//
//            for articlePreview in searchResults.items {
//                print(articlePreview.displayTitle)
//            }
//        }

        let _ = Wikipedia.shared.requestArticle(language: language, title: "Soft rime", imageWidth: 640) { result in
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

