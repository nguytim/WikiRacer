//
//  GameVC.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 2/25/21.
//

import UIKit
import WikipediaKit
import WebKit

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
    
    var game: Game?
    
    // game mechanics
    var startingArticle: Article?
    var targetArticle: Article?
    
    var currentArticle: Article?
    var previousArticles = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewForEmbedingWebView.isHidden = true
        
        self.navigationController?.navigationBar.isHidden = true
        
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
        
        game = Game(startingArticle: startingArticle!.lastPathComponentURL, targetArticle: targetArticle!.lastPathComponentURL)
        
        getArticle(article: currentArticle!.lastPathComponentURL)
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
        currentArticle = Article(title: newArticle, lastPathComponentURL: newArticle)
        
        backButton.isHidden = false
        
        // navigate to the new Wiki article
        getArticle(article: newArticle)
        updateCounter()
        
        print("Current article: \(currentArticle!.lastPathComponentURL)")
        print("Target article: \(targetArticle!.lastPathComponentURL)")
        
        // user wins the game and the current article matches the target article
        if currentArticle!.lastPathComponentURL == targetArticle!.lastPathComponentURL {
            timer.invalidate()
            game?.elapsedTime = timeDisplayed
            print("CONGRATULATIONS!! YOU WON!")
            performSegue(withIdentifier: "YouWinSegueIdentifier", sender: nil)
        }
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
    
    // update the counter by 1
    func updateCounter() {
        game!.numLinks += 1
        counterLabel.text = String(game!.numLinks)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "YouWinSegueIdentifier",
           let youWinVC = segue.destination as? YouWinVC {
            youWinVC.game = game
        }
    }
    
    // Convert to NSAttributedString
    func htmlToString(htmlString: String) -> NSAttributedString {
        let htmlString = htmlString
        let data = htmlString.data(using: .utf8)!
        let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        return attributedString!
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // REMOVE HEADER, WIKI ACTIONS, AND FOOTER
        let elementClassesToRemove = ["header-container header-chrome", "page-actions-menu", "mw-footer minerva-footer", "box-Multiple_issues plainlinks metadata ambox ambox-content ambox-multiple_issues compact-ambox", "reference", "unicode haudio", "edit-page menu__item--page-actions-edit mw-ui-icon mw-ui-icon-element mw-ui-icon-wikimedia-editLock-base20 mw-ui-icon-with-label-desktop", "mw-editsection"]
        
        for elementClassName in elementClassesToRemove {
            let removeElementClassScript = "var elements = document.getElementsByClassName('\(elementClassName)'); for (var i = elements.length - 1; i >= 0; i--) { elements[i].parentNode.removeChild(elements[i]);}"
            webView.evaluateJavaScript(removeElementClassScript) { (response, error) in
                debugPrint("Am here")
            }
        }
        
        let elementIdsToRemove = ["References", "Bibliography", "External_links", "Notes", "Further_reading", "Footnotes"]
        
        for elementId in elementIdsToRemove {
            let removeElementIdScript = "var element = document.getElementById('\(elementId)'); if (element != null) {element.parentNode.parentNode.removeChild(element.parentNode);}"
            webView.evaluateJavaScript(removeElementIdScript) { (response, error) in
                debugPrint("Could not remove stuff")
            }
        }
        
        // CHANGE THE STYLING OF LINKS
        let changeLinksToButtonsScript = "var elements = document.getElementsByTagName('a'); var j = 0; for (var i = 0; i < elements.length; i++) { if (elements[i].className != null && elements[i].className != 'image') {if (j == 0) { elements[i].style.backgroundColor='#E8787A';} else if (j == 1) { elements[i].style.backgroundColor='#7EEABF';} else if (j == 2) { elements[i].style.backgroundColor='#F0B351';} else { elements[i].style.backgroundColor='#8FDE60'; j = -1;} elements[i].style.color='white'; elements[i].style.fontWeight='700'; elements[i].style.borderRadius='7px'; j++;}}"
        webView.evaluateJavaScript(changeLinksToButtonsScript) { (response, error) in
            debugPrint("Am here")
        }
        viewForEmbedingWebView.isHidden = false
    }
}
