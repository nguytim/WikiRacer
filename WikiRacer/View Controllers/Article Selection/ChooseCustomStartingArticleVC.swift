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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: RoundedButton!
    
    var isMultiplayer: Bool?
    var gameType: String?
    
    let language = WikipediaLanguage("en")
    
    let customTargetArticleIdentifier = "CustomTargetArticleSegueIdentifier"
    let viewGameSegueIdentifier = "ViewGameSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isMultiplayer != nil {
            titleLabel.text = "Multiplayer"
        }
        
        WikipediaNetworking.appAuthorEmailForAPI = "maniponce22@gmail.com"
        setupUsernameTextfield(isDarkMode: CURRENT_USER!.settings.darkModeEnabled)
        
        confirmButton.setTitleColor(.systemGray, for: .disabled)
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
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        // ERROR
        confirmButton.isEnabled = false
        if inputArticleText.text == "" {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "Article cannot be blank!"
            confirmButton.isEnabled = true
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
                self.confirmButton.isEnabled = true
            case .failure(let error):
              print(error)
                self.errorMessageLabel.isHidden = false
                self.errorMessageLabel.text = "\(article) is not an existing Wiki article!"
                self.confirmButton.isEnabled = true
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
    
    private func setupUsernameTextfield(isDarkMode: Bool) {
        let borderWidth = CGFloat(2.0)
        
        //USERNAME
        let usernameBorder = CALayer()
        usernameBorder.frame = CGRect(x: 0, y: inputArticleText.frame.size.height - borderWidth, width: inputArticleText.frame.size.width, height: borderWidth)
        usernameBorder.borderWidth = borderWidth
        
        inputArticleText.layer.addSublayer(usernameBorder)
        inputArticleText.layer.masksToBounds = true
        
        
        ///adjust color based on dark mode
        if(isDarkMode) {
            usernameBorder.borderColor = UIColor.white.cgColor
            inputArticleText.attributedPlaceholder = NSAttributedString(string: "Example Article",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        else {
            usernameBorder.borderColor = UIColor.black.cgColor
            inputArticleText.attributedPlaceholder = NSAttributedString(string: "Example Article",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        }
    }
    

}
