//
//  ForgotPasswordViewController.swift
//  WikiRacer
//
//  Created by Manuel on 3/11/21.
//

import UIKit

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
    
    private func setupButton() {
        let attributedString = NSAttributedString(string: NSLocalizedString("Send Reset Link", comment: ""), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0), NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.underlineStyle:1.0] as [NSAttributedString.Key : Any])
        sendResetLinkButton.setAttributedTitle(attributedString, for: .normal)
        sendResetLinkButton.setTitleColor(.white, for: .normal)
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
