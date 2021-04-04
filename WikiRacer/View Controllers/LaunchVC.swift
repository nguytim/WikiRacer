//
//  LaunchVC.swift
//  WikiRacer
//
//  Created by Tracy on 4/4/21.
//

import UIKit
import FirebaseAuth

class LaunchVC: UIViewController {
    
    private let backgroundView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        imageView.image = UIImage(named: "SplashCheckers")
        imageView.alpha = 0.5
        return imageView
    }()
    
    private let racerView:UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y:0, width: 340, height: 140))
        imageView.image = UIImage(named: "FrontViewRacer")
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundView)
        view.addSubview(racerView)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.center = view.center
        racerView.center = view.center
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.animate()
        })
    }
    
    private func animate() {
        UIView.animate(withDuration: 0.5, animations: {
            let size = self.view.frame.size.width * 2.5
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            
            self.racerView.frame = CGRect(x: -(diffX/2), y: diffY/2, width: size, height: size)
        })
        
        UIView.animate(withDuration: 1.3, animations: {
            self.racerView.alpha = 0
            self.backgroundView.alpha = 0
        }, completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                    self.performSegue(withIdentifier: "LaunchSegueIdentifier", sender: nil)
                })
            }
        })
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
