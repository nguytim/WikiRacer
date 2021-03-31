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
    
    let startGameIdentifier = "StartGameIdentifier"
    let leaderboardCellIdentifier = "LeaderboardCellIdentifier"
    
    var game: Game?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.navigationController?.viewControllers = [self]
        
        checkIfUserHasPlayedAlready()
        
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        
        codeLabel.text = game?.code
        startingArticleLabel.text = game?.startingArticle.title
        targetArticleLabel.text = game?.targetArticle.title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game!.leaderboard!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: leaderboardCellIdentifier, for: indexPath as IndexPath) as! LeaderboardTableCell
        let player = game!.leaderboard![indexPath.row]
        
        cell.rankLabel.text = "#\(indexPath.row + 1)"
        cell.playerLabel.text = player.name
        cell.timeLabel.text = player.time
        cell.linksLabel.text = "\(player.numLinks)"
        
        return cell
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
        performSegue(withIdentifier: startGameIdentifier, sender: nil)
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
