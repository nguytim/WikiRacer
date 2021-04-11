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
    let startGameIdentifier = "StartGameIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) 
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // resets navigation to this VC
        self.navigationController?.viewControllers = [self]
        self.navigationController?.navigationBar.isHidden = true
        
        self.tabBarController?.tabBar.isHidden = false
        if CURRENT_USER!.settings.darkModeEnabled {
            // adopt a light interface style
            overrideUserInterfaceStyle = .dark
        } else {
            // adopt a dark interface style
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // unhides navigation bar when homeVC disappears
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func singlePlayerButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: gameTypeIdentifier, sender: nil)
    }
    
    @IBAction func multiplayerButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: gameTypeIdentifier, sender: true)
    }
    
    func goToViewGameVC(game: Game) {
        performSegue(withIdentifier: startGameIdentifier, sender: game)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gameTypeIdentifier,
           let gameTypeVC = segue.destination as? GameTypeVC {
            if sender != nil {
                gameTypeVC.isMultiplayer = true
            }
        } else if segue.identifier == startGameIdentifier,
                  let gameVC = segue.destination as? GameVC {
            let game = sender as! Game
            gameVC.startingArticle = game.startingArticle
            gameVC.targetArticle = game.targetArticle
            gameVC.isMultiplayer = true
            gameVC.game = game
        }
    }
}
