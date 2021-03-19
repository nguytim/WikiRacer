//
//  ShopVC.swift
//  WikiRacer
//
//  Created by Manuel Ponce on 3/19/21.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseAuth

class Hat{
    var cost: Int
    var name: String
    
    init(cost:Int, name:String){
        self.cost = cost
        self.name = name
        
    }
}

class ItemCollectionCell: UICollectionViewCell{
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var costLabel: UILabel!
    
}

class ShopVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var db: Firestore!
    var hats = [Hat]()

    @IBOutlet weak var shopGrid: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        shopGrid.delegate = self
        shopGrid.dataSource = self
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        //[End setup]
        db = Firestore.firestore()
                // Do any additional setup after loading the view.
        loadShop()
    }
    
    
    func collectionView(_ collectionView:  UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return hats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath as IndexPath) as! ItemCollectionCell
       let hat = hats[indexPath.row]
    
        cell.costLabel.text = "\(hat.cost)"
        return cell
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func buyButtonPressed(_ sender: Any) {
    }
    
    func loadShop() {
        let docRef = db!.collection("shop").document("accessories")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let hatsData = data!["hats"] as! [Any]
                
               
                
                for i in 0...hatsData.count - 1 {
                    let hat = hatsData[i] as! [String: Any]
                    self.hats.append(
                        Hat(cost: hat["cost"] as! Int,
                               name: hat["name"] as! String)
                               
                    )
                }
                print(self.hats)
                self.shopGrid.reloadData()
                
            }
        }
        
    }    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
