//
//  YouWinVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import UIKit

class YouWinVC: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numLinksLabel: UILabel!
    
    var game: Game?

    override func viewDidLoad() {
        super.viewDidLoad()
        let timeDisplayed = game!.elapsedTime
        let minutes = (timeDisplayed % 3600) / 60
        let seconds = (timeDisplayed % 3600) % 60
        timeLabel.text = String(format:"%d:%02d", minutes, seconds)
        numLinksLabel.text = "\(game!.numLinks)"
    }

    @IBAction func playAgainButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func newGameButtonPressed(_ sender: Any) {
        
    }
    
    // multiplayer
    @IBAction func leaderboardButtonPressed(_ sender: Any) {
        
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
