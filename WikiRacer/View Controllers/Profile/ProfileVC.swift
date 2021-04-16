//
//  ProfileVC.swift
//  WikiRacer
//
//  Created by Manuel Ponce on 3/19/21.
//

import UIKit

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
        settingsButton.center.x += view.bounds.width
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.settingsButton.center.x -= self.view.bounds.width
        })
        changeDarkMode()
        loadStats()
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToSettingsIdentifier",
           let settingsVC = segue.destination as? SettingsVC {
            settingsVC.delegate = self
        }
    }
    
    
}

