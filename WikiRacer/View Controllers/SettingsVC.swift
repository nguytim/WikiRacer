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
    var docRef: DocumentReference!
    var delegate: UIViewController!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var signOutButt: UIButton!
    @IBOutlet weak var deleteAccountButt: UIButton!
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var colorfulButtonsSwitch: UISwitch!
    @IBOutlet weak var soundEffectsSwitch: UISwitch!
    @IBOutlet weak var notificiationsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        loadUserSettings()
        
        let user = Auth.auth().currentUser
        if let user = user {
            emailLabel.text = user.email
        }
        
        setupButtons()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CURRENT_USER!.settings.darkModeEnabled {
            // adopt a light interface style
            overrideUserInterfaceStyle = .dark
        } else {
            // adopt a dark interface style
            overrideUserInterfaceStyle = .light
        }
    }
    
    func loadUserSettings() {
        usernameLabel.text = CURRENT_USER!.username
        darkModeSwitch.isOn = CURRENT_USER!.settings.darkModeEnabled
        colorfulButtonsSwitch.isOn = CURRENT_USER!.settings.colorfulButtonsEnabled
        soundEffectsSwitch.isOn = CURRENT_USER!.settings.soundEffectsEnabled
        notificiationsSwitch.isOn = CURRENT_USER!.settings.notificationsEnabled
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
        darkModeSwitch.isEnabled = false
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                var settings = data!["settings"] as! Dictionary<String, Bool>
                
                settings["darkModeEnabled"] = self.darkModeSwitch.isOn
                CURRENT_USER!.settings.darkModeEnabled = self.darkModeSwitch.isOn
                
                if CURRENT_USER!.settings.darkModeEnabled {
                    // adopt a light interface style
                    self.overrideUserInterfaceStyle = .dark
                } else {
                    // adopt a dark interface style
                    self.overrideUserInterfaceStyle = .light
                }
                
                let profileVC = self.delegate as! ChangeToDarkMode
                profileVC.changeDarkMode()
                
                self.docRef.updateData(["settings": settings])
                self.darkModeSwitch.isEnabled = true
            }
        }
    }
    
    @IBAction func gameplayColorsSwitchToggled(_ sender: Any) {
        colorfulButtonsSwitch.isEnabled = false
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                var settings = data!["settings"] as! Dictionary<String, Bool>
                
                settings["colorfulButtonsEnabled"] = self.colorfulButtonsSwitch.isOn
                CURRENT_USER!.settings.colorfulButtonsEnabled = self.colorfulButtonsSwitch.isOn
                
                self.docRef.updateData(["settings": settings])
                self.colorfulButtonsSwitch.isEnabled = true
            }
        }
    }
    
    @IBAction func soundEffectsSwitchToggled(_ sender: Any) {
        soundEffectsSwitch.isEnabled = false
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                var settings = data!["settings"] as! Dictionary<String, Bool>
                
                settings["soundEffectsEnabled"] = self.soundEffectsSwitch.isOn
                CURRENT_USER!.settings.soundEffectsEnabled = self.soundEffectsSwitch.isOn
                
                self.docRef.updateData(["settings": settings])
                self.soundEffectsSwitch.isEnabled = true
            }
        }
    }
    
    @IBAction func notificationsSwitchToggled(_ sender: Any) {
        notificiationsSwitch.isEnabled = false
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                var settings = data!["settings"] as! Dictionary<String, Bool>
                
                settings["notificationsEnabled"] = self.notificiationsSwitch.isOn
                CURRENT_USER!.settings.notificationsEnabled = self.notificiationsSwitch.isOn
                
                self.docRef.updateData(["settings": settings])
                self.notificiationsSwitch.isEnabled = true
            }
        }
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
