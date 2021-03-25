//
//  SettingsVC.swift
//  WikiRacer
//
//  Created by Tracy on 3/19/21.
//

import UIKit
import FirebaseAuth

class SettingsVC: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        if let user = user {
            emailLabel.text = user.email
        }

        // Do any additional setup after loading the view.
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
}
