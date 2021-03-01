//
//  ViewController.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 2/25/21.
//

import UIKit
import WikipediaKit

class ViewController: UIViewController {

    @IBOutlet weak var wikiTitle: UILabel!
    @IBOutlet weak var wikiDescription: UITextView!
    
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

        let _ = Wikipedia.shared.requestArticle(language: language, title: "Attack on Titan", imageWidth: 640) { result in
            switch result {
            case .success(let article):
                self.wikiTitle.text = article.displayTitle
                let htmlString = article.displayText
                let data = htmlString.data(using: .utf8)!
                let attributedString = try? NSAttributedString(
                    data: data,
                    options: [.documentType: NSAttributedString.DocumentType.html],
                    documentAttributes: nil)
                self.wikiDescription.attributedText = attributedString
                self.wikiDescription.sizeToFit()
//              print(article.displayTitle)
//              print(article.displayText)
            case .failure(let error):
              print(error)
            }
        }
        
    }


}

