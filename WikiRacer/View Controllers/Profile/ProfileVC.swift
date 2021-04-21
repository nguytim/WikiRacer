//
//  ProfileVC.swift
//  WikiRacer
//
//  Created by Manuel Ponce on 3/19/21.
//

import UIKit
import FirebaseStorage

protocol ChangeToDarkMode {
    func changeDarkMode()
}

class ProfileVC: UIViewController, ChangeToDarkMode {
    
    @IBOutlet weak var settingsButton: UIButton!
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        leastNumLinksLabel.alpha = 0
        fastestTimeLabel.alpha = 0
        avgLinksLabel.alpha = 0
        avgGameTimeLabel.alpha = 0
        numGamesWonLabel.alpha = 0
        numGamesLabel.alpha = 0
        changeDarkMode()
        loadStats()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0, delay: 0, options: [],
                       animations: {
                        self.leastNumLinksLabel.alpha = 1
                        self.fastestTimeLabel.alpha = 1
                        self.avgLinksLabel.alpha = 1
                        self.avgGameTimeLabel.alpha = 1
                        self.numGamesWonLabel.alpha = 1
                        self.numGamesLabel.alpha = 1
                       }, completion: nil)
        settingsButton.center.x += view.bounds.width
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.settingsButton.center.x -= self.view.bounds.width
        })
        loadCharacter()
    }
    
    func changeDarkMode() {
        if CURRENT_USER!.settings.darkModeEnabled {
            // adopt a light interface style
            overrideUserInterfaceStyle = .dark
        } else {
            // adopt a dark interface style
            overrideUserInterfaceStyle = .light
        }
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
        let username = CURRENT_USER!.username
        let numGames = CURRENT_USER!.stats.gamesPlayed
        let gamesWon = CURRENT_USER!.stats.gamesWon
        let totalTime = CURRENT_USER!.stats.totalGameTime
        let totalLinks = CURRENT_USER!.stats.totalNumberOfLinks
        let fastestTime = CURRENT_USER!.stats.fastestGame
        let leastNumLinks = CURRENT_USER!.stats.leastNumberOfLinks
        let blah = CURRENT_USER!.racer.currentRacer
        debugPrint("blah is: ")
        debugPrint(blah)
        
        var avgTime = 0
        var avgLinks = 0
        
        if gamesWon != 0 {
            avgTime = totalTime / gamesWon
            avgLinks = totalLinks / gamesWon
        }
        
        
        let minutesAvgTime = (avgTime % 3600) / 60
        let secondsAvgTime = (avgTime % 3600) % 60
        
        let minutesFastestTime = (fastestTime % 3600) / 60
        let secondsFastestTime = (fastestTime % 3600) % 60
        
        userNameLabel.text = String(username)
        numGamesLabel.text = String(numGames)
        numGamesWonLabel.text = String(gamesWon)
        fastestTimeLabel.text = String(format:"%d:%02d", minutesFastestTime, secondsFastestTime)
        leastNumLinksLabel.text = String(leastNumLinks)
        avgLinksLabel.text = String(avgLinks)
        avgGameTimeLabel.text = String(format:"%d:%02d", minutesAvgTime, secondsAvgTime)
        
        showLabels()
        
    }
    
    func loadCharacter() {
        let storageRef = Storage.storage().reference()
        let racersRef = storageRef.child("racers")
        let characterImageRef = racersRef.child("\(CURRENT_USER!.racer.currentRacer)")
        characterImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                let image = self.resizeImage(image: UIImage(data: data!)!, targetSize: CGSize(width: 240, height: 242))
                self.racerImage.image = image
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size

            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height

            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }

            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage!
        }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToSettingsIdentifier",
           let settingsVC = segue.destination as? SettingsVC {
            settingsVC.delegate = self
        }
    }
    
    
}

