//
//  ChooseCustomStartingArticleVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/16/21.
//

import UIKit
import WikipediaKit

class ChooseCustomStartingArticleVC: UIViewController {
    
    let language = WikipediaLanguage("en")
    
    let customTargetArticleIdentifier = "CustomTargetArticleSegueIdentifier"

    @IBOutlet weak var inputArticleText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WikipediaNetworking.appAuthorEmailForAPI = "maniponce22@gmail.com"
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        // ERROR
        if inputArticleText.text == "" {
            print("ERROR: Article cannot be blank and must be a valid name")
        } else {
            getArticle(article: inputArticleText.text!)
        }
    }
    
    func getArticle(article: String) {
        let _ = Wikipedia.shared.requestArticle(language: language, title: article, imageWidth: 640) { result in
            switch result {
            case .success(let article):
                let title = "\(article.url!.lastPathComponent)".replacingOccurrences(of: "_", with: " ")
                let article = Article(title: "\(title)", lastPathComponentURL: "\(article.url!.lastPathComponent)")
                self.goToGame(article: article)
            case .failure(let error):
              print(error)
            }
        }
    }
    
    func goToGame(article: Article) {
        performSegue(withIdentifier: customTargetArticleIdentifier, sender: article)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == customTargetArticleIdentifier,
            let customTargetArticleVC = segue.destination as? ChooseCustomTargetArticleVC {
            customTargetArticleVC.startingArticle = sender as! Article
        }
    }
    

}
