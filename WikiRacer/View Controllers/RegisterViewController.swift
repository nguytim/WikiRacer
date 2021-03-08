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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    // code to enable tapping on the background to remove software keyboard
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
}
