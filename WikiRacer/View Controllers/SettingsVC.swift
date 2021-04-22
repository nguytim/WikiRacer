//
//  SettingsVC.swift
//  WikiRacer
//
//  Created by Tracy on 3/19/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SettingsVC: UIViewController {
    
    
    var db: Firestore!
    var docRef: DocumentReference!
    var delegate: UIViewController!
    @IBOutlet weak var colorSlider: UISlider!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernametextLabel: UILabel!
    
    
    @IBOutlet weak var signOutButt: UIButton!
    @IBOutlet weak var deleteAccountButt: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var soundEffectsSwitch: UISwitch!
    @IBOutlet weak var notificiationsSwitch: UISwitch!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        if Auth.auth().currentUser != nil {
            docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
            let user = Auth.auth().currentUser
            if let user = user {
                emailLabel.text = user.email
            }
        } else {
            deleteAccountButt.isHidden = true
            editButton.isHidden = true
            usernameTextField.isUserInteractionEnabled = false
            signOutButt.setTitle("Return to Login", for: .normal)
        }
        
        loadUserSettings()
        setupButtons()
        setupUsernameTextfield(isDarkMode: CURRENT_USER!.settings.darkModeEnabled)
        
        //Version number the app is on
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = "Version \(appVersionString)"
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
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func loadUserSettings() {
        usernameTextField.placeholder = CURRENT_USER!.username
        darkModeSwitch.isOn = CURRENT_USER!.settings.darkModeEnabled
        colorSlider.value = Float(CURRENT_USER!.settings.gameplayButtonColor)
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
    
    @IBAction func colorSliderChanged(_ sender: Any) {
        //        selectedColorView.backgroundColor = uiColorFromHex(colorArray[Int(slider.value)])
        if Auth.auth().currentUser != nil {
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    var settings = data!["settings"] as! Dictionary<String, Any>
                    
                    settings["gameplayButtonColor"] = round(self.colorSlider.value)
                    CURRENT_USER!.settings.gameplayButtonColor = Int(round(self.colorSlider.value))
                    
                    self.docRef.updateData(["settings": settings])
                }
            }
        } else {
            CURRENT_USER!.settings.gameplayButtonColor = Int(round(self.colorSlider.value))
        }
    }
    
    
    @IBAction func darkModeSwitchToggled(_ sender: Any) {
        darkModeSwitch.isEnabled = false
        if Auth.auth().currentUser != nil {
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    var settings = data!["settings"] as! Dictionary<String, Bool>
                    
                    settings["darkModeEnabled"] = self.darkModeSwitch.isOn
                    CURRENT_USER!.settings.darkModeEnabled = self.darkModeSwitch.isOn
                    //update for textfield too
                    self.setupUsernameTextfield(isDarkMode: self.darkModeSwitch.isOn)
                    
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
        } else {
            CURRENT_USER!.settings.darkModeEnabled = self.darkModeSwitch.isOn
            //update for textfield too
            self.setupUsernameTextfield(isDarkMode: self.darkModeSwitch.isOn)
            if CURRENT_USER!.settings.darkModeEnabled {
                // adopt a light interface style
                self.overrideUserInterfaceStyle = .dark
            } else {
                // adopt a dark interface style
                self.overrideUserInterfaceStyle = .light
            }
            let profileVC = self.delegate as! ChangeToDarkMode
            profileVC.changeDarkMode()
            self.darkModeSwitch.isEnabled = true
        }
    }
    
    @IBAction func soundEffectsSwitchToggled(_ sender: Any) {
        soundEffectsSwitch.isEnabled = false
        if Auth.auth().currentUser != nil {
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
        } else {
            CURRENT_USER!.settings.soundEffectsEnabled = self.soundEffectsSwitch.isOn
            self.soundEffectsSwitch.isEnabled = true
        }
    }
    
    @IBAction func notificationsSwitchToggled(_ sender: Any) {
        notificiationsSwitch.isEnabled = false
        if Auth.auth().currentUser != nil {
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
        } else {
            CURRENT_USER!.settings.notificationsEnabled = self.notificiationsSwitch.isOn
            self.notificiationsSwitch.isEnabled = true
        }
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "LoginIdentifier", sender: self)
        }
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
        if(usernameTextField.text != nil && !usernameTextField.text!.isEmpty) {
            print("made it inside newusername != ")
            let docRef = Firestore.firestore().collection("usernames").whereField("username", isEqualTo: usernameTextField.text!.lowercased()).limit(to: 1)
            docRef.getDocuments { (querysnapshot, error) in
                if error != nil {
                    print("Document Error: ", error!)
                } else {
                    if let doc = querysnapshot?.documents, !doc.isEmpty {
                        //unsuccessful registration
                        let alert = UIAlertController(title: "Username is taken", message: "Please try a different username.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        //change the username bc it not currently existing and is valid
                        
                        //Change GOBLAL users username.
                        CURRENT_USER?.username = self.usernameTextField.text!
                        
                        //change current Authenticated users Display Name
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = self.usernameTextField.text!
                        changeRequest?.commitChanges(completion: nil)
                        
                        //change usernames user database
                        self.db.collection("usernames").document(CURRENT_USER!.usernameID).setData([ "username": self.usernameTextField.text! ])
                        
                        //change corresponding users database for that users username
                        self.db.collection("users").document(Auth.auth().currentUser!.uid).setData(["username": self.usernameTextField.text!], merge: true)
                        
                        //Let user know they have successfully changed their username.
                        let alert = UIAlertController(title: "Congrats!", message: "You have updated your username.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Wohoo!", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        //Reset the textfield and display new username
                        self.usernameTextField.text = ""
                        self.usernameTextField.placeholder = CURRENT_USER?.username
                    }
                }
            }
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please make sure new username is not empty.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    private func setupButtons() {
        signOutButt.backgroundColor = UIColor(named: "MainDarkColor")
        signOutButt.setTitleColor(.white, for: .normal)
        signOutButt.layer.cornerRadius = 17.0
        
        editButton.backgroundColor = UIColor(named: "MainDarkColor")
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 17.0
        
        //Attribute to underline button text.
        let attributedString = NSAttributedString(string: NSLocalizedString("Delete Account", comment: ""), attributes:[
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0),
            NSAttributedString.Key.foregroundColor : UIColor.red,
            NSAttributedString.Key.underlineStyle:1.0
        ])
        deleteAccountButt.setAttributedTitle(attributedString, for: .normal)
        
    }
    
    private func setupUsernameTextfield(isDarkMode: Bool) {
        let borderWidth = CGFloat(2.0)
        
        //USERNAME
        let usernameBorder = CALayer()
        usernameBorder.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - borderWidth, width: usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
        usernameBorder.borderWidth = borderWidth
        
        usernameTextField.layer.addSublayer(usernameBorder)
        usernameTextField.layer.masksToBounds = true
        
        
        ///adjust color based on dark mode
        if(isDarkMode) {
            usernameBorder.borderColor = UIColor.white.cgColor
            usernameTextField.attributedPlaceholder = NSAttributedString(string: CURRENT_USER!.username,
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        else {
            usernameBorder.borderColor = UIColor.black.cgColor
            usernameTextField.attributedPlaceholder = NSAttributedString(string: CURRENT_USER!.username,
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        }
    }
    
    // code to enable tapping on the background to remove software keyboard
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
        
    
}
