//
//  GameVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 2/25/21.
//

import UIKit
import WikipediaKit
import WebKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class GameVC: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    @IBOutlet weak var viewForEmbedingWebView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var startingArticleLabel: UILabel!
    @IBOutlet weak var targetArticleLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    var timer = Timer()
    var timeDisplayed = 0
    
    // Wikipedia language set to english
    let language = WikipediaLanguage("en")
    
    let youWinSegueIdentifier = "YouWinSegueIdentifier"
    let exitSegueIdentifier = "ExitIdentifier"
    
    let colors = ["#7EEABF", "#8FDE60", "#F0B351", "#E8787A"]
    
    var game: Game?
    var isMultiplayer: Bool = false
    
    // game mechanics
    var startingArticle: Article?
    var targetArticle: Article?
    
    var currentArticle: Article?
    var previousArticles = [Article]()
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewForEmbedingWebView.isHidden = true
        
        self.navigationController?.navigationBar.isHidden = true
        
        // resets navigation to this VC
        self.navigationController?.viewControllers = [self]
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        // update games played for user stats
        updateGamesPlayed()
        
        // set up webview
        webView = WKWebView(frame: viewForEmbedingWebView.bounds, configuration: WKWebViewConfiguration())
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.allowsLinkPreview = false
        viewForEmbedingWebView.addSubview(webView)
        
        timerLabel.text = "0:00"
        counterLabel.text = "0"
        
        startTimer()
        
        currentArticle = startingArticle
        
        startingArticleLabel.text = startingArticle!.title
        targetArticleLabel.text = targetArticle!.title
        print("Starting article: \(startingArticle!.title)")
        print("Target article: \(targetArticle!.title)")
        
        if !isMultiplayer {
            game = Game(startingArticle: startingArticle!, targetArticle: targetArticle!)
        }
        
        getArticle(article: currentArticle!.lastPathComponentURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        if CURRENT_USER!.settings.darkModeEnabled {
            // adopt a light interface style
            overrideUserInterfaceStyle = .dark
        } else {
            // adopt a dark interface style
            overrideUserInterfaceStyle = .light
        }
        
    }
    
    // update games played for user
    func updateGamesPlayed() {
        if Auth.auth().currentUser != nil {
            
            
            let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    var stats = data!["stats"] as! Dictionary<String, Int>
                    stats["gamesPlayed"]! += 1
                    docRef.updateData(["stats": stats])
                    CURRENT_USER!.stats.gamesPlayed = stats["gamesPlayed"]!
                }
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if isMultiplayer {
            updateGamesPlayed()
            // TODO INVALIDATE GAME and add player to leaderboard
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
    @objc func fireTimer() {
        timeDisplayed += 1
        //        let hours = timeDisplayed / 3600
        let minutes = (timeDisplayed % 3600) / 60
        let seconds = (timeDisplayed % 3600) % 60
        timerLabel.text = String(format:"%d:%02d", minutes, seconds)
    }
    
    // retrieves the Wiki article and updates the UILabel of the title and UITextview of the description
    func getArticle(article: String) {
        let _ = Wikipedia.shared.requestArticle(language: language, title: article, imageWidth: 640) { result in
            switch result {
            case .success(let article):
                
                // GO TO URL
                let myRequest = URLRequest(url: article.url!)
                self.webView.load(myRequest)
                
                self.currentArticle = Article(title: article.displayTitle, lastPathComponentURL: article.url!.lastPathComponent)
                
                print("Current article Title : \(self.currentArticle!.title)")
                print("Target article Title: \(self.targetArticle!.title)")
                print("Current article URL: \(self.currentArticle!.lastPathComponentURL)")
                print("Target article URL: \(self.targetArticle!.lastPathComponentURL)")
                
                // user wins the game and the current article matches the target article
                if self.currentArticle!.lastPathComponentURL == self.targetArticle!.lastPathComponentURL {
                    self.timer.invalidate()
                    self.game?.elapsedTime = self.timeDisplayed
                    print("CONGRATULATIONS!! YOU WON!")
                    self.performSegue(withIdentifier: "YouWinSegueIdentifier", sender: nil)
                }
                
            case .failure(let error):
                print("Can't find article: \(article)")
                print(error)
            }
        }
    }
    
    // handles when a link is clicked on in the WebView
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            print("link")
            guard let url = navigationAction.request.url else {
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
            goToArticle(url: url)
            
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        print("no link")
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    // go to the Wiki article given its url
    func goToArticle(url: URL) {
        // store the current article in previous articles
        previousArticles.append(currentArticle!)
        print("Appended \(currentArticle!.title)")
        
        // get the new article from the last path component of the URL
        let newArticle = url.lastPathComponent
        
        backButton.isHidden = false
        updateCounter()
        
        // navigate to the new Wiki article
        getArticle(article: newArticle)
    }
    
    // on button click, user can go back to previous article
    @IBAction func backButtonClicked(_ sender: Any) {
        
        // get the previous article
        currentArticle = previousArticles.popLast()!
        print("Go to previous article \(currentArticle!.lastPathComponentURL)")
        getArticle(article: currentArticle!.lastPathComponentURL)
        
        updateCounter()
        
        // hide the back button when there are no more previous articles
        if previousArticles.isEmpty {
            backButton.isHidden = true
        }
    }
    
    @IBAction func exitButtonClicked(_ sender: Any) {
        var message = "Are you sure you want to end the game?"
        if isMultiplayer {
            message = "Are you sure you want to end the game? You will not be able to replay this multiplayer game."
        }
        let exitAlert = UIAlertController(title: "Exit", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Go Back", style: .default) { (action) in
            exitAlert.dismiss(animated: true, completion: nil)
        }
        
        let exitAction = UIAlertAction(title: "Exit", style: .destructive) { (action) in
            let uid = Auth.auth().currentUser!.uid
            let username = Auth.auth().currentUser!.displayName!
            
            let currentPlayer = Player(uid: uid, name: username, time: -1, numLinks: -1)
            
            // add to leaderboard
            self.game!.leaderboard!.append(currentPlayer)
            
            let db: Firestore = Firestore.firestore()
            db.collection("games").document(self.game!.code!).setData(self.game!.dictionary)
            self.performSegue(withIdentifier: self.exitSegueIdentifier, sender: nil)
        }
        
        exitAlert.addAction(cancelAction)
        exitAlert.addAction(exitAction)
        
        self.present(exitAlert, animated: true, completion: nil)
    }
    
    // update the counter by 1
    func updateCounter() {
        game!.numLinks += 1
        counterLabel.text = String(game!.numLinks)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "YouWinSegueIdentifier",
           let youWinVC = segue.destination as? YouWinVC {
            youWinVC.game = game
            youWinVC.isMultiplayer = isMultiplayer
            if isMultiplayer {
                
                let uid = Auth.auth().currentUser!.uid
                let username = Auth.auth().currentUser!.displayName!
                
                let currentPlayer = Player(uid: uid, name: username, time: game!.elapsedTime, numLinks: game!.numLinks)
                
                // add to leaderboard
                game!.leaderboard!.append(currentPlayer)
                
                let db: Firestore = Firestore.firestore()
                db.collection("games").document(game!.code!).setData(game!.dictionary)
            }
        }
    }
    
    func insertContentsOfCSSFile(into webView: WKWebView) {
        guard let path = Bundle.main.path(forResource: "styles", ofType: "css") else { debugPrint("Nothing found"); return; }
        debugPrint("path is: \(path)")
        let cssString = try! String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines)
        debugPrint("cssString is: \(cssString)")
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        debugPrint("Done adding style")
        webView.evaluateJavaScript(jsString, completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // REMOVE HEADER, WIKI ACTIONS, AND FOOTER
        let elementClassesToRemove = ["header-container header-chrome", "page-actions-menu", "mw-footer minerva-footer", "box-Multiple_issues plainlinks metadata ambox ambox-content ambox-multiple_issues compact-ambox", "reference", "unicode haudio", "edit-page menu__item--page-actions-edit mw-ui-icon mw-ui-icon-element mw-ui-icon-wikimedia-editLock-base20 mw-ui-icon-with-label-desktop", "mw-editsection", "box-More_citations_needed plainlinks metadata ambox ambox-content ambox-Refimprove"]
        
        for elementClassName in elementClassesToRemove {
            let removeElementClassScript = "var elements = document.getElementsByClassName('\(elementClassName)'); for (var i = elements.length - 1; i >= 0; i--) { elements[i].parentNode.removeChild(elements[i]);}"
            webView.evaluateJavaScript(removeElementClassScript) { (response, error) in
                debugPrint("Am here")
            }
        }
        
        let elementIdsToRemove = ["References", "Bibliography", "External_links", "Notes", "Further_reading", "Footnotes", "mw-head", "mw-panel"]
        
        for elementId in elementIdsToRemove {
            let removeElementIdScript = "var element = document.getElementById('\(elementId)'); if (element != null) {element.parentNode.parentNode.removeChild(element.parentNode);}"
            webView.evaluateJavaScript(removeElementIdScript) { (response, error) in
                debugPrint("Could not remove stuff")
            }
        }
        
        if CURRENT_USER!.settings.gameplayButtonColor != 0 {
            //if CURRENT_USER!.settings.colorfulButtonsEnabled {
            // CHANGE THE STYLING OF LINKS
            let changeLinksToButtonsScript = "var elements = document.getElementsByTagName('a'); var j = 0; for (var i = 0; i < elements.length; i++) { if (elements[i].className != null && elements[i].className != 'image') { elements[i].style.backgroundColor='\(colors[CURRENT_USER!.settings.gameplayButtonColor - 1])'; elements[i].style.color='white'; elements[i].style.fontWeight='700'; elements[i].style.borderRadius='7px';}}"
            webView.evaluateJavaScript(changeLinksToButtonsScript) { (response, error) in
                debugPrint("Am here")
            }
        }
        insertContentsOfCSSFile(into: webView)
        viewForEmbedingWebView.isHidden = false
    }
}
