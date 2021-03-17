//
//  GameTypeVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/16/21.
//

import UIKit

class GameTypeVC: UIViewController {
    
    @IBOutlet weak var normalButton: RoundedButton!
    @IBOutlet weak var timeTrialButton: RoundedButton!
    @IBOutlet weak var leastLinksButton: RoundedButton!
    @IBOutlet weak var customButton: RoundedButton!
    @IBOutlet weak var goBackButton: RoundedButton!
    
    var isMultiplayer: Bool = false
    var isTimeTrial: Bool = true
    
    let selectArticlesIdentifier = "SelectArticlesSegueIdentifier"
    let customArticleIdentifier = "CustomGameSegueIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isMultiplayer {
            normalButton.isHidden = true
            customButton.isHidden = true
            timeTrialButton.isHidden = false
            leastLinksButton.isHidden = false
        }
    }
    
    @IBAction func normalButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: selectArticlesIdentifier, sender: nil)
    }
    
    @IBAction func customButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: customArticleIdentifier, sender: isMultiplayer)
    }
    
    @IBAction func timeTrialButtonPressed(_ sender: Any) {
        isTimeTrial = true
        multiplayerModesToGameModes()
    }
    
    @IBAction func leastLinksButtonPressed(_ sender: Any) {
        isTimeTrial = false
        multiplayerModesToGameModes()
    }
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        gameModesToMultiplayerModes()
    }
    
    func multiplayerModesToGameModes() {
        timeTrialButton.isHidden = true
        leastLinksButton.isHidden = true
        normalButton.isHidden = false
        customButton.isHidden = false
        goBackButton.isHidden = false
    }
    
    func gameModesToMultiplayerModes() {
        timeTrialButton.isHidden = false
        leastLinksButton.isHidden = false
        normalButton.isHidden = true
        customButton.isHidden = true
        goBackButton.isHidden = true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == selectArticlesIdentifier,
            let chooseArticleVC = segue.destination as? ChooseStartingArticleVC {
            // CHECK MULTIPLAYER and WHICH TRAIL
            
        } else if segue.identifier == customArticleIdentifier {
            // CHECK MULTIPLAYER AND WHICH TRIAL
        }
    }

}
