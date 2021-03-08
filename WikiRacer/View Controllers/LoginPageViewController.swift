//
//  LoginPageViewController.swift
//  WikiRacer
//
//  Created by Manuel on 3/7/21.
//

import UIKit
import FirebaseAuth

class LoginPageViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    //Code for firebase login
    @IBAction func logInButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!, completion: {user, error in
            if error == nil {
                //successful login
                self.performSegue(withIdentifier: "GmailSegue", sender: nil)
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
        if segue.identifier == "GmailSegue" {
            guard let vc = segue.destination as? LoginPageViewController else { return }
        }
        
//        segue.destination.modalPresentationStyle = .fullScreen
    }
    
    // code to enable tapping on the background to remove software keyboard
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
}
