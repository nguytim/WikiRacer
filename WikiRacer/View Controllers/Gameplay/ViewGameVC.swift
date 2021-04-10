//
//  ViewGameVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/18/21.
//

import UIKit
import FirebaseAuth

class LeaderboardTableCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var linksLabel: UILabel!
}

class ViewGameVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var startingArticleLabel: UILabel!
    @IBOutlet weak var targetArticleLabel: UILabel!
    @IBOutlet weak var leaderboardTableView: UITableView!
    @IBOutlet weak var startButton: RoundedButton!
    @IBOutlet weak var gameTypeLabel: UILabel!
    
    let startGameIdentifier = "StartGameIdentifier"
    let leaderboardCellIdentifier = "LeaderboardCellIdentifier"
    
    var game: Game?
    var backViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if backViewController == nil {
            backViewController = storyboard!.instantiateViewController(withIdentifier: "HomeVC")
        }
        self.navigationController?.viewControllers = [backViewController!, self]
        
        checkIfUserHasPlayedAlready()
        
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        
        gameTypeLabel.text = game?.gameType
        codeLabel.text = game?.code
        startingArticleLabel.text = game?.startingArticle.title
        targetArticleLabel.text = game?.targetArticle.title
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game!.leaderboard!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: leaderboardCellIdentifier, for: indexPath as IndexPath) as! LeaderboardTableCell
        let player = game!.leaderboard![indexPath.row]
        
        let timeDisplayed = player.time
        let minutes = (timeDisplayed % 3600) / 60
        let seconds = (timeDisplayed % 3600) % 60
        let time = String(format:"%d:%02d", minutes, seconds)
        
        cell.rankLabel.text = "#\(indexPath.row + 1)"
        cell.playerLabel.text = player.name
        cell.timeLabel.text = time
        cell.linksLabel.text = "\(player.numLinks)"
        
        if game?.gameType == "Time Trial" {
            cell.timeLabel.font = UIFont.boldSystemFont(ofSize: 17)
        } else {
            cell.linksLabel.font = UIFont.boldSystemFont(ofSize: 17)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func checkIfUserHasPlayedAlready() {
        let uid = Auth.auth().currentUser!.uid
        for player in game!.leaderboard! {
            if player.uid == uid {
                self.startButton.isHidden = true
                break
            }
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        // if we're already on Home tab
        if self.tabBarController?.selectedIndex == 2 {
            performSegue(withIdentifier: startGameIdentifier, sender: nil)
        } else {
            self.tabBarController?.selectedIndex = 2
            let homeVC = self.tabBarController!.viewControllers![2].children[0] as? HomeVC
            homeVC!.goToViewGameVC(game: game!)
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == startGameIdentifier,
           let gameVC = segue.destination as? GameVC {
            gameVC.startingArticle = game?.startingArticle
            gameVC.targetArticle = game?.targetArticle
            gameVC.isMultiplayer = true
            gameVC.game = game
        }
    }
    
}
