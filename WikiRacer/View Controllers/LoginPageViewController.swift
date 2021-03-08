//
//  LoginPageViewController.swift
//  WikiRacer
//
//  Created by Manuel on 3/7/21.
//

import UIKit
import FirebaseAuth
import WikipediaKit

class LoginPageViewController: UIViewController {
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let language = WikipediaLanguage("en")

        let _ = Wikipedia.shared.requestOptimizedSearchResults(language: language, term: "Movies") { (searchResults, error) in

            guard error == nil else { return }
            guard let searchResults = searchResults else { return }

            for articlePreview in searchResults.items {
                print(articlePreview.displayTitle)
            }
        }
//        let language = WikipediaLanguage("en")
//
//        let randomDay = Int.random(in: 1..<1500)
//
//        let dayBeforeYesterday = Date(timeIntervalSinceNow: TimeInterval(-60 * 60 * 24 * randomDay))
//
//        let _ = Wikipedia.shared.requestFeaturedArticles(language: language, date: dayBeforeYesterday) { result in
//            switch result {
//            case .success(let featuredCollection):
//                for a in featuredCollection.mostReadArticles {
//                    print(a.displayTitle)
//                }
//                print("Random Day: \(randomDay)")
//                print("Num of articles: \(featuredCollection.mostReadArticles.count)")
//            case .failure(let error):
//              print(error)
//            }
//        }
    }
    
    
    //Code for firebase login
    @IBAction func logInButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailAddressTextField.text!, password: passwordTextField.text!, completion: {user, error in
            if error == nil {
                //successful login
                self.performSegue(withIdentifier: "SignInIdentifier", sender: nil)
            } else {
                //unsuccessful login
                let alert = UIAlertController(title: "Error", message: "Could not login. Check your email and password", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func SignUpButton(_ sender: Any) {
    }
    
    @IBAction func gmailLoginButton(_ sender: Any) {
        performSegue(withIdentifier: "GmailSegue", sender: self)
    }
    
    //Fake segue to test
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "GmailSegue" {
//            guard let vc = segue.destination as? LoginPageViewController else { return }
//        }
        
//        segue.destination.modalPresentationStyle = .fullScreen
    }
    
    // code to enable tapping on the background to remove software keyboard
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
}
