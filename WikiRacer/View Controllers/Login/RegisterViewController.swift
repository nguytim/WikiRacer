//
//  RegisterViewController.swift
//  WikiRacer
//
//  Created by Manuel on 3/7/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpGmailButton: UIButton!
    
    var globalUsernames: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupRegisterButtons()
        setupTextFields()
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        if(!emailAddressTextField.text!.isEmpty && !passwordTextField.text!.isEmpty && !usernameTextField.text!.isEmpty) {
            let docRef = Firestore.firestore().collection("usernames").whereField("username", isEqualTo: usernameTextField.text!.lowercased()).limit(to: 1)
            docRef.getDocuments { (querysnapshot, error) in
                if error != nil {
                    print("Document Error: ", error!)
                } else {
                    if let doc = querysnapshot?.documents, !doc.isEmpty {
                        print("Document is present.")
                        print("Username is NOT available")
                        //unsuccessful registration
                        let alert = UIAlertController(title: "Username is taken", message: "Please try a different username.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        Auth.auth().createUser(withEmail: self.emailAddressTextField.text!, password: self.passwordTextField.text!, completion: {user, error in
                            if error == nil {
                                //successful registration
                                
                                //Add user to database and default their profile settings
                                let collection = Firestore.firestore().collection("users")
                                let usernameCollection = Firestore.firestore().collection("usernames")
                                
                                //Add Default Racer collection under the newly created user.
                                let racerCollection = collection.document(Auth.auth().currentUser!.uid).collection("racer").document()
                                
                                //Create a document for a new username being registered.
                                usernameCollection.document().setData(["username": self.usernameTextField.text!.lowercased()])
                                
                                let user = User(username: self.usernameTextField.text!, racer: racerCollection.documentID, points: 0, gamesWon: 0, gamesPlayed: 0, averageGameTime: 0, fastestGame: 0, averageNumberOfLinks: 0, leastNumberofLink: 0, usernameID: self.usernameTextField.text!)
                                
                                //Create a document for the user collection with the key being the users UID given by Firebase Authentication.
                                collection.document(Auth.auth().currentUser!.uid).setData(user.dictionary)
                                
                                //Create a document for the racer collection inside that newly created user collection.
                                let racer = Racer(accessoriesOwned: ["None"], currentAccessorries: ["None"], currentRacer: "Default")
                                collection.document(Auth.auth().currentUser!.uid).collection("racer").document(racerCollection.documentID).setData(racer.dictionary)
                                
                                //Add Display Name to Firebase Authentication.
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = self.usernameTextField.text
                                changeRequest?.commitChanges(completion: nil)
                                
                                
                                
                                //Send to main page.
                                self.performSegue(withIdentifier: "RegisterToMainIdentifier", sender: nil)
                            } else {
                                //unsuccessful registration
                                let alert = UIAlertController(title: "Oops", message: "Could not register user. Try again.", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        })
                    }
                }
            }
        }
        else {
            //Username or Password is empty
            let alert = UIAlertController(title: "Oops", message: "Please make sure Username, Email, and Password are not empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Function that styles the buttons
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
    
    //Function to style the text fields
    private func setupTextFields() {
        
        let borderWidth = CGFloat(2.0)
        
        //USERNAME
        let usernameBorder = CALayer()
        usernameBorder.borderColor = UIColor.white.cgColor
        usernameBorder.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - borderWidth, width: usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
        usernameBorder.borderWidth = borderWidth
        
        usernameTextField.layer.addSublayer(usernameBorder)
        usernameTextField.layer.masksToBounds = true
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        //EMAIL
        let emailBorder = CALayer()
        emailBorder.borderWidth = borderWidth
        emailBorder.borderColor = UIColor.white.cgColor
        emailBorder.frame = CGRect(x: 0, y: emailAddressTextField.frame.size.height - borderWidth, width: emailAddressTextField.frame.size.width, height: emailAddressTextField.frame.size.height)

        emailAddressTextField.layer.addSublayer(emailBorder)
        emailAddressTextField.layer.masksToBounds = true
        emailAddressTextField.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        //PASSWORD
        let passwordBorder = CALayer()
        passwordBorder.borderWidth = borderWidth
        passwordBorder.borderColor = UIColor.white.cgColor
        passwordBorder.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - borderWidth, width: passwordTextField.frame.size.width, height: passwordTextField.frame.size.height)

        passwordTextField.layer.addSublayer(passwordBorder)
        passwordTextField.layer.masksToBounds = true
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
