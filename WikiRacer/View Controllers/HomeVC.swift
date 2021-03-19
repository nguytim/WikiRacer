//
//  HomeVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import UIKit
import WikipediaKit

class HomeVC: UIViewController {
    
    let gameTypeIdentifier = "GameTypeSegueIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // resets navigation to this VC
        self.navigationController?.viewControllers = [self]
    }

    // unhides navigation bar when homeVC disappears
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func singlePlayerButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: gameTypeIdentifier, sender: nil)
    }
    
    @IBAction func multiplayerButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: gameTypeIdentifier, sender: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gameTypeIdentifier,
            let gameTypeVC = segue.destination as? GameTypeVC {
            if sender != nil {
                gameTypeVC.isMultiplayer = true
            }
        }
    }

}
