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
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        UIPasteboard.general.string = game!.code!
        // the alert view
        let alert = UIAlertController(title: "Code copied", message: "\(game!.code!) copied to clipboard!", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
          // your code with delay
          alert.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // Setting description
        let firstActivityItem = "Race against me in WikiRacer! Here's my game code: \(game!.code!)"

        // Setting url
//        let secondActivityItem : NSURL = NSURL(string: "http://your-url.com/")!
        
        // If you want to use an image
//        let image : UIImage = UIImage(named: "AppIcon")!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
        UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
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
