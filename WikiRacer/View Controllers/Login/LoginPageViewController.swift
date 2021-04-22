//
//  LoginPageViewController.swift
//  WikiRacer
//
//  Created by Manuel on 3/7/21.
//

import UIKit
import FirebaseAuth
import WikipediaKit
import FirebaseFirestore

class LoginPageViewController: UIViewController {
    
    @IBOutlet weak var logoLabel: UILabel!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var continueAsGuestButton: UIButton!
    
    
    let collectionOfUsers = Firestore.firestore().collection("users")
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Before screen is shown make sure they dont have a logged in user in the cache.
        checkLoggedInUser()
        
        self.logoLabel.alpha = 0
        self.emailAddressTextField.alpha = 0
        self.passwordTextField.alpha = 0
        self.loginButton.alpha = 0
        self.signUpButton.alpha = 0
        self.forgotPasswordButton.alpha = 0
        self.continueAsGuestButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupButtons()
        setupTextField()
        
        self.logoLabel.center.y -= view.bounds.width
        self.loginButton.alpha = 0
        self.forgotPasswordButton.alpha = 0
        
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
                        self.continueAsGuestButton.alpha = 1
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
                
                let docRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let username = data!["username"] as! String
                        let usernameID = data!["usernameID"] as! String
                        let points = data!["points"] as! Int
                        
                        // USER STATS
                        
                        let stats = data!["stats"] as! Dictionary<String, Int>
                        let gamesPlayed = stats["gamesPlayed"]!
                        let gamesWon = stats["gamesWon"]!
                        let totalGameTime = stats["totalGameTime"]!
                        let totalNumberOfLinks = stats["totalNumberOfLinks"]!
                        let fastestGame = stats["fastestGame"]!
                        let leastNumberOfLinks = stats["leastNumberOfLinks"]!
                        
                        let userStats = Stats(gamesPlayed: gamesPlayed, gamesWon: gamesWon, totalGameTime: totalGameTime, totalNumberOfLinks: totalNumberOfLinks, fastestGame: fastestGame, leastNumberOfLinks: leastNumberOfLinks)
                        
                        // USER'S RACER
                        
                        let racer = data!["racer"] as! Dictionary<String, Any>
                        let accessoriesOwned = racer["accessoriesOwned"] as! [String]
                        let racecarsOwned = racer["racecarsOwned"] as! [String]
                        let racersOwned = racer["racersOwned"] as! [String]
                        let currentAccessorries = racer["currentAccessorries"] as! [String]
                        let currentRacecar = racer["currentRacecar"] as! String
                        let currentRacer = racer["currentRacer"] as! String
                        
                        let userRacer = Racer(accessoriesOwned: accessoriesOwned, racecarsOwned: racecarsOwned, racersOwned: racersOwned, currentAccessorries: currentAccessorries, currentRacecar: currentRacecar, currentRacer: currentRacer)
                        
                        // USER SETTINGS
                        let settings = data!["settings"] as! Dictionary<String, Any>
                        let darkModeEnabled = settings["darkModeEnabled"] as! NSNumber
                        let gameplayButtonColor = settings["gameplayButtonColor"] as! NSNumber
                        let soundEffectsEnabled = settings["soundEffectsEnabled"] as! NSNumber
                        let notificationsEnabled = settings["notificationsEnabled"] as! NSNumber
                        
                        let userSettings = Settings(darkModeEnabled: darkModeEnabled.boolValue, gameplayButtonColor: gameplayButtonColor.intValue, soundEffectsEnabled: soundEffectsEnabled.boolValue, notificationsEnabled: notificationsEnabled.boolValue)
                        
                        // SET GLOBAL CURRENT USER
                        CURRENT_USER = User(username: username, usernameID: usernameID, points: points, stats: userStats, racer: userRacer, settings: userSettings)
                        
                        self.performSegue(withIdentifier: "SignInIdentifier", sender: nil)
                    }
                }
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
    
//    //Guest segue to test
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//                if segue.identifier == "GuestSegueIdentifier" {
//                    guard let vc = segue.destination as? LoginPageViewController else { return }
//                }
//        
//                segue.destination.modalPresentationStyle = .fullScreen
//    }
    
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
                
        continueAsGuestButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Continue as Guest", comment: ""), attributes:[
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0),
            NSAttributedString.Key.foregroundColor : UIColor.gray,
            NSAttributedString.Key.underlineStyle:1.0
        ]), for: .normal)
    }
    
    @IBAction func contAsGuestButtonSegue(_ sender: Any) {
        let defaultStats = Stats(gamesPlayed: 0, gamesWon: 0, totalGameTime: 0, totalNumberOfLinks: 0, fastestGame: 0, leastNumberOfLinks: 0)
        
        let defaultRacer = Racer(accessoriesOwned: [String](), racecarsOwned: [], racersOwned: [], currentAccessorries: [String](), currentRacecar: "", currentRacer: "")
        
        let defaultSettings = Settings(darkModeEnabled: false, gameplayButtonColor: Int(1), soundEffectsEnabled: true, notificationsEnabled: true)
        
        let user = User(username: "Guest", usernameID: "Guest", points: 0, stats: defaultStats, racer: defaultRacer, settings: defaultSettings)
        
        CURRENT_USER = user
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
    
    private func checkLoggedInUser() {
        self.view.isHidden = true
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user == nil {
                debugPrint("user is nil")
                self.view.isHidden = false
                self.emailAddressTextField.text = nil
                self.passwordTextField.text = nil
            }
            else {
                
                let docRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let username = data!["username"] as! String
                        let usernameID = data!["usernameID"] as! String
                        let points = data!["points"] as! Int
                        
                        // USER STATS
                        
                        let stats = data!["stats"] as! Dictionary<String, Int>
                        let gamesPlayed = stats["gamesPlayed"]!
                        let gamesWon = stats["gamesWon"]!
                        let totalGameTime = stats["totalGameTime"]!
                        let totalNumberOfLinks = stats["totalNumberOfLinks"]!
                        let fastestGame = stats["fastestGame"]!
                        let leastNumberOfLinks = stats["leastNumberOfLinks"]!
                        
                        let userStats = Stats(gamesPlayed: gamesPlayed, gamesWon: gamesWon, totalGameTime: totalGameTime, totalNumberOfLinks: totalNumberOfLinks, fastestGame: fastestGame, leastNumberOfLinks: leastNumberOfLinks)
                        
                        // USER'S RACER
                        
                        let racer = data!["racer"] as! Dictionary<String, Any>
                        let accessoriesOwned = racer["accessoriesOwned"] as! [String]
                        let racecarsOwned = racer["racecarsOwned"] as! [String]
                        let racersOwned = racer["racersOwned"] as! [String]
                        let currentAccessorries = racer["currentAccessorries"] as! [String]
                        let currentRacecar = racer["currentRacecar"] as! String
                        let currentRacer = racer["currentRacer"] as! String
                        
                        let userRacer = Racer(accessoriesOwned: accessoriesOwned, racecarsOwned: racecarsOwned, racersOwned: racersOwned, currentAccessorries: currentAccessorries, currentRacecar: currentRacecar, currentRacer: currentRacer)
                        
                        // USER SETTINGS
                        let settings = data!["settings"] as! Dictionary<String, Any>
                        let darkModeEnabled = settings["darkModeEnabled"] as! NSNumber
                        //  let colorfulButtonsEnabled = settings["colorfulButtonsEnabled"]!
                        let gameplayButtonColor = settings["gameplayButtonColor"] as! NSNumber
                        let soundEffectsEnabled = settings["soundEffectsEnabled"] as! NSNumber
                        let notificationsEnabled = settings["notificationsEnabled"] as! NSNumber
                        
                        let userSettings = Settings(darkModeEnabled: darkModeEnabled.boolValue, gameplayButtonColor: gameplayButtonColor.intValue, soundEffectsEnabled: soundEffectsEnabled.boolValue, notificationsEnabled: notificationsEnabled.boolValue)
                        
                        // SET GLOBAL CURRENT USER
                        CURRENT_USER = User(username: username, usernameID: usernameID, points: points, stats: userStats, racer: userRacer, settings: userSettings)
                        
                        self.performSegue(withIdentifier: "SignInIdentifier", sender: nil)
                    }
                }
            }
        }
    }
    
}
