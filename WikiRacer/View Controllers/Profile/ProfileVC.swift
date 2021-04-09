//
//  ProfileVC.swift
//  WikiRacer
//
//  Created by Manuel Ponce on 3/19/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

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
        hideLabels()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadStats()
    }
    
    func hideLabels() {
        numGamesLabel.isHidden = true
        numGamesWonLabel.isHidden = true
        fastestTimeLabel.isHidden = true
        leastNumLinksLabel.isHidden = true
        userNameLabel.isHidden = true
        avgLinksLabel.isHidden = true
        avgGameTimeLabel.isHidden = true
    }
    
    func showLabels() {
        numGamesLabel.isHidden = false
        numGamesWonLabel.isHidden = false
        fastestTimeLabel.isHidden = false
        leastNumLinksLabel.isHidden = false
        userNameLabel.isHidden = false
        avgLinksLabel.isHidden = false
        avgGameTimeLabel.isHidden = false
    }
    
    func loadStats() {
        let docRef = db!.collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let userName = data!["username"] as! String
                let numGames = data!["gamesPlayed"] as! Int
                let gamesWon = data!["gamesWon"] as! Int
                let totalTime = data!["averageGameTime"] as! Int
                let totalLinks = data!["averageNumberOfLinks"] as! Int
                let fastestTime = data!["fastestGame"] as! Int
                let leastNumLinks = data!["leastNumberofLink"] as! Int
                
                let avgTime = totalTime / gamesWon
                let avgLinks = totalLinks / gamesWon
                
                let minutesAvgTime = (avgTime % 3600) / 60
                let secondsAvgTime = (avgTime % 3600) % 60
                
                let minutesFastestTime = (fastestTime % 3600) / 60
                let secondsFastestTime = (fastestTime % 3600) % 60
                
                self.numGamesLabel.text = String(numGames)
                self.numGamesWonLabel.text = String(gamesWon)
                self.fastestTimeLabel.text = String(format:"%d:%02d", minutesFastestTime, secondsFastestTime)
                self.leastNumLinksLabel.text = String(leastNumLinks)
                self.userNameLabel.text = String(userName)
                self.avgLinksLabel.text = String(avgLinks)
                self.avgGameTimeLabel.text = String(format:"%d:%02d", minutesAvgTime, secondsAvgTime)
                
                self.showLabels()
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

