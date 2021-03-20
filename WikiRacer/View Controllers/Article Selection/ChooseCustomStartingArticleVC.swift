//
//  ChooseCustomStartingArticleVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/16/21.
//

import UIKit
import WikipediaKit

class ChooseCustomStartingArticleVC: UIViewController {

    @IBOutlet weak var inputArticleText: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    var isMultiplayer: Bool?
    var gameType: String?
    
    let language = WikipediaLanguage("en")
    
    let customTargetArticleIdentifier = "CustomTargetArticleSegueIdentifier"
    let viewGameSegueIdentifier = "ViewGameSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WikipediaNetworking.appAuthorEmailForAPI = "maniponce22@gmail.com"
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        // ERROR
        if inputArticleText.text == "" {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "Article cannot be blank!"
        } else {
            errorMessageLabel.isHidden = true
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
                self.errorMessageLabel.isHidden = false
                self.errorMessageLabel.text = "\(article) is not an existing Wiki article!"
            }
        }
    }
    
    func goToGame(article: Article) {
        performSegue(withIdentifier: customTargetArticleIdentifier, sender: article)
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == customTargetArticleIdentifier,
            let customTargetArticleVC = segue.destination as? ChooseCustomTargetArticleVC {
            customTargetArticleVC.startingArticle = sender as? Article
            if isMultiplayer != nil {
                customTargetArticleVC.isMultiplayer = isMultiplayer
                customTargetArticleVC.gameType = gameType
            }
        }
    }
    

}
