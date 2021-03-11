//
//  RegisterViewController.swift
//  WikiRacer
//
//  Created by Manuel on 3/7/21.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpGmailButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupRegisterButtons()
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        if(!usernameTextField.text!.isEmpty && !passwordTextField.text!.isEmpty) {
            Auth.auth().createUser(withEmail: emailAddressTextField.text!, password: passwordTextField.text!, completion: {user, error in
                if error == nil {
                    //successful registration
                    
//                    //Add user to database and default their profile settings
//                    let collection = Firestore.firestore().collection("users")
//                    let user = User(
//                        username: self.emailField.text!,
//                        favoriteSport: "noFavoriteSport :(",
//                        hometown: "noHometown :(",
//                        major: "noMajor :(",
//                        profilePicture: "https://picsum.photos/200/300",
//                        userUid: Auth.auth().currentUser!.uid)
//                    collection.document(Auth.auth().currentUser!.uid).setData(user.dictionary)
                    
                    //Add Display Name
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.usernameTextField.text
                    changeRequest?.commitChanges(completion: nil)
                    
                    //Send to main page.
                    self.performSegue(withIdentifier: "RegisterToMainIdentifier", sender: nil)
                } else {
                    //unsuccessful registration
                    let alert = UIAlertController(title: "Error", message: "Could not register user", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        else {
            //Username or Password is empty
            let alert = UIAlertController(title: "Error", message: "Please make sure Username or Password are not empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func setupRegisterButtons() {
        //Attribute to underline button text.
        let attributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0), NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.underlineStyle:1.0] as [NSAttributedString.Key : Any]
        var attributedString = NSAttributedString(string: NSLocalizedString("Sign up", comment: ""), attributes: attributes)
        signUpButton.setAttributedTitle(attributedString, for: .normal)
        signUpButton.setTitleColor(.white, for: .normal)
        
        attributedString = NSAttributedString(string: NSLocalizedString("Sign up with Gmail", comment: ""), attributes: attributes)
        signUpGmailButton.setAttributedTitle(attributedString, for: .normal)
        signUpGmailButton.setTitleColor(.white, for: .normal)
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
