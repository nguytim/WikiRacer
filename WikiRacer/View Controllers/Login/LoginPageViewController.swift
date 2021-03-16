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
    
    @IBOutlet weak var logoLabel: UILabel!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var gmailButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.logoLabel.alpha = 0
        self.emailAddressTextField.alpha = 0
        self.passwordTextField.alpha = 0
        self.loginButton.alpha = 0
        self.signUpButton.alpha = 0
        self.gmailButton.alpha = 0
        self.forgotPasswordButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupButtons()
        setupTextField()
        
        self.logoLabel.center.y -= view.bounds.width
        self.loginButton.alpha = 0
        self.forgotPasswordButton.alpha = 0
        self.gmailButton.alpha = 0
        
        self.loginButton.center.x -= self.view.bounds.width
        self.signUpButton.center.x += self.view.bounds.width
        
        UIView.animate(withDuration: 1.0,
            delay: 0.5,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0.3,
            options: [],
            animations: {
                self.logoLabel.alpha = 1.0
                self.logoLabel.center.y += self.view.bounds.width
            })
        UIView.animate(withDuration: 1.5, delay: 1.0, options: [],
            animations: {
                self.emailAddressTextField.alpha = 1
                self.passwordTextField.alpha = 1
                self.forgotPasswordButton.alpha = 1
                self.gmailButton.alpha = 1
            }, completion: nil)
        UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [],
            animations: {
                self.loginButton.alpha = 1
                self.signUpButton.alpha = 1
                self.loginButton.center.x += self.view.bounds.width
                self.signUpButton.center.x -= self.view.bounds.width
            }, completion: nil)
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
    
    private func setupButtons() {
        loginButton.backgroundColor = UIColor(named: "MainDarkColor")
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 17.0
        
        signUpButton.backgroundColor = UIColor(named: "MainDarkColor")
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 17.0
        
        //Attribute to underline button text.
        let attributedString = NSAttributedString(string: NSLocalizedString("Login with Gmail", comment: ""), attributes:[
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0),
            NSAttributedString.Key.foregroundColor : UIColor.gray,
            NSAttributedString.Key.underlineStyle:1.0
        ])
        gmailButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func setupTextField() {
        emailAddressTextField.backgroundColor = UIColor.white
        emailAddressTextField.layer.borderColor = UIColor.lightGray.cgColor
        emailAddressTextField.layer.cornerRadius = 5.0
        emailAddressTextField.layer.borderWidth = 1.0
        emailAddressTextField.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        
        passwordTextField.backgroundColor = UIColor.white
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.cornerRadius = 5.0
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
}
