//
//  SettingsVC.swift
//  WikiRacer
//
//  Created by Tracy on 3/19/21.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsVC: UIViewController {
    
    var db: Firestore!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var signOutButt: UIButton!
    @IBOutlet weak var deleteAccountButt: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        loadUsername()
        
        let user = Auth.auth().currentUser
        if let user = user {
            emailLabel.text = user.email
        }
        
        setupButtons()

        // Do any additional setup after loading the view.
    }
    
    func loadUsername() {
        let docRef = db!.collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let userName = data!["username"] as! String
                
                self.usernameLabel.text = String(userName)
                
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
    @IBAction func darkModeSwitchToggled(_ sender: Any) {
    }
    @IBAction func soundEffectsSwitchToggled(_ sender: Any) {
    }
    @IBAction func notificationsSwitchToggled(_ sender: Any) {
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "LoginIdentifier", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func deleteAccountClicked(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This will permanently erase all data.", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            
            let user = Auth.auth().currentUser
            
            // TODO: delete account data and info in database
            
            // delete user in authentication
            user?.delete { error in
                if let error = error {
                    print(error)
                } else {
                    print("User deleted.")
                }
            }
            self.performSegue(withIdentifier: "LoginIdentifier", sender: self)
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func editUsernameButtonClicked(_ sender: Any) {
        
    }
    
    
    private func setupButtons() {
                signOutButt.backgroundColor = UIColor(named: "MainDarkColor")
                signOutButt.setTitleColor(.white, for: .normal)
                signOutButt.layer.cornerRadius = 17.0
        
        //Attribute to underline button text.
        let attributedString = NSAttributedString(string: NSLocalizedString("Delete Account", comment: ""), attributes:[
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0),
            NSAttributedString.Key.foregroundColor : UIColor.red,
            NSAttributedString.Key.underlineStyle:1.0
        ])
        deleteAccountButt.setAttributedTitle(attributedString, for: .normal)
        
    }
}
