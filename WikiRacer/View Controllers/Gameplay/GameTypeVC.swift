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
    
    var isMultiplayer: Bool = false
    
    let selectArticlesIdentifier = "SelectArticlesSegueIdentifier"
    let customArticleIdentifier = "CustomGameSegueIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isMultiplayer {
            normalButton.isHidden = true
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
        performSegue(withIdentifier: selectArticlesIdentifier, sender: nil)
    }
    
    @IBAction func leastLinksButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: selectArticlesIdentifier, sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == selectArticlesIdentifier,
            let chooseArticleVC = segue.destination as? ChooseStartingArticleVC {
            // CHECK MULTIPLAYER
            
        } else if segue.identifier == customArticleIdentifier {
            // CHECK MULTIPLAYER
        }
    }

}
