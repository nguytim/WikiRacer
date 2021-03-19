//
//  ProfileVC.swift
//  WikiRacer
//
//  Created by Manuel Ponce on 3/19/21.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileVC: UIViewController {
    var db: Firestore!

    @IBOutlet weak var leastNumLinksLabel: UILabel!
    @IBOutlet weak var fastestTimeLabel: UILabel!
    @IBOutlet weak var avgLinksLabel: UILabel!
    @IBOutlet weak var avgGameTimeLabel: UILabel!
    @IBOutlet weak var numGamesWonLabel: UILabel!
    @IBOutlet weak var numGamesLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var racerImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        //[End setup]
        db = Firestore.firestore()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        loadStats()
    }
    
    
    func loadStats() {
        let docRef = db!.collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let userName = data!["username"] as! String
                let numGames = data!["gamesPlayed"] as! Int
                let gamesWon = data!["gamesWon"] as! Int
                let avgTime = data!["averageGameTime"] as! Int
                let avgLinks = data!["averageNumberOfLinks"] as! Int
                let fastestTime = data!["fastestGame"] as!  Int
                let leastNumLinks = data!["leastNumberofLink"] as! Int
                
                self.numGamesLabel.text = String(numGames)
                self.numGamesWonLabel.text = String(gamesWon)
                self.fastestTimeLabel.text = String(fastestTime)
                self.leastNumLinksLabel.text = String(leastNumLinks)
                self.userNameLabel.text = String(userName)
                self.avgLinksLabel.text = String(avgLinks)
                self.avgGameTimeLabel.text = String(avgTime)
                
                
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

