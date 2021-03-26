//
//  RacerVC.swift
//  WikiRacer
//
//  Created by Tracy on 3/25/21.
//

import UIKit

class RacerVC: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var hatImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.characterImage.center.x -= self.view.bounds.width
        self.carImage.center.x += self.view.bounds.width
        
        UIView.animate(withDuration: 1.0, delay: 0.5,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.2,
                       options: [],
                       animations: {
                        self.characterImage.center.x += self.view.bounds.width
                        self.carImage.center.x -= self.view.bounds.width
                       },
                       completion: nil)
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
