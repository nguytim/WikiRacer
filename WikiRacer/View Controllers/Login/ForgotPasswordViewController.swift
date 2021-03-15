//
//  ForgotPasswordViewController.swift
//  WikiRacer
//
//  Created by Manuel on 3/11/21.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var sendResetLinkButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTextField()
        setupButton()
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Function 2 make our text field to look cool.
    private func setupTextField() {
        let usernameBorder = CALayer()
        let borderWidth = CGFloat(2.0)
        usernameBorder.borderColor = UIColor.white.cgColor
        usernameBorder.frame = CGRect(x: 0, y: emailAddressTextField.frame.size.height - borderWidth, width: emailAddressTextField.frame.size.width, height: emailAddressTextField.frame.size.height)
        usernameBorder.borderWidth = borderWidth
        
        emailAddressTextField.layer.addSublayer(usernameBorder)
        emailAddressTextField.layer.masksToBounds = true
        emailAddressTextField.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    //Function to make our buttons look cool and styalized.
    private func setupButton() {
        let attributedString = NSAttributedString(string: NSLocalizedString("Send Reset Link", comment: ""), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0), NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.underlineStyle:1.0] as [NSAttributedString.Key : Any])
        sendResetLinkButton.setAttributedTitle(attributedString, for: .normal)
        sendResetLinkButton.setTitleColor(.white, for: .normal)
    }
    
    //Code that runs when 'Send Reset Link' is clicked.
    //This code will check the email entered by the user and
    //      Firebase will authenticate it for us and send
    //      the user an email to that account to reset their password.
    @IBAction func sendResetLinkButton(_ sender: Any) {
        if !emailAddressTextField.text!.isEmpty {
            let emailAddress = emailAddressTextField.text!

            Auth.auth().sendPasswordReset(withEmail: emailAddress) {error in
                if error != nil {
                    //Bad Email, let the user know.
                    let controller = UIAlertController(title: "Bad Email",
                                                       message: "Please enter a valid email to an account.",
                                                       preferredStyle: .alert)
                    
                    controller.addAction(UIAlertAction(title: "OK",
                                                       style: .default,
                                                       handler: nil))
                    self.present(controller, animated: true, completion: nil)
                }
                else {
                    //Succesful email entry and set the user a reset to that email.
                    let controller = UIAlertController(title: "Email sent",
                                                       message: "Please wait a few moments for the email to reach you. Happy Racing!",
                                                       preferredStyle: .alert)
                    
                    controller.addAction(UIAlertAction(title: "OK",
                                                       style: .default,
                                                       handler: nil))
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
