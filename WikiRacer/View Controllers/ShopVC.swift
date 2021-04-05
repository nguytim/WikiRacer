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
import FirebaseFirestore

class Item {
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
    var storageRef: StorageReference!
    var hatsRef: StorageReference!
    var racecarsRef: StorageReference!
    var racersRef: StorageReference!
    
    var shopItems = [Item]()
    var hatsCount = 0
    var racecarsCount = 0
    var racersCount = 0
    
    @IBOutlet weak var shopGrid: UICollectionView!
    @IBOutlet weak var moneyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shopGrid.delegate = self
        shopGrid.dataSource = self
        shopGrid.isHidden = true
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        storageRef = Storage.storage().reference()
        hatsRef = storageRef.child("hats")
        racecarsRef = storageRef.child("racecars")
        racersRef = storageRef.child("racers")
        
        loadShop()
    }
    
    
    func collectionView(_ collectionView:  UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath as IndexPath) as! ItemCollectionCell
        let index = indexPath.row
        let item = shopItems[index]
        
        let cost = NSMutableAttributedString(string:"\(item.cost)")
        let fuel = NSTextAttachment()
        fuel.image = resizeImage(image: UIImage(named: "fuel.png")!, targetSize: CGSize(width: 17, height: 17))
        let fuelText = NSAttributedString(attachment: fuel)
        cost.append(fuelText)
        
        cell.costLabel.attributedText = cost
        
        // Create a reference to the file you want to download
        let count = index
        
        var itemImages: StorageReference
        if count < hatsCount {
            itemImages = hatsRef.child("\(item.name)")
        } else if count < hatsCount + racecarsCount {
            itemImages = racecarsRef.child("\(item.name)")
        } else {
            itemImages = racersRef.child("\(item.name)")
        }
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        itemImages.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            // Uh-oh, an error occurred!
            print(error)
          } else {
            // Data for "images/island.jpg" is returned
            let image = UIImage(data: data!)
            cell.image.image = image
          }
        }
        
        cell.layer.borderWidth = 3
        
        if cell.isSelected {
            //put border logic
            cell.layer.borderColor = UIColor.systemGray.cgColor
            cell.contentView.backgroundColor = UIColor(red: 199/256, green: 199/256, blue: 204/256, alpha: 1)
            
        } else {
            // remove border
            cell.layer.borderColor = UIColor(red: 199/256, green: 199/256, blue: 204/256, alpha: 1).cgColor
            cell.contentView.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    // load shop items
    func loadShop() {
        let docRef = db!.collection("shop").document("items")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                // get shop item category
                let hatsData = data!["hats"] as! [Any]
                let racecarsData = data!["racecars"] as! [Any]
                let racersData = data!["racers"] as! [Any]
                
                // get the length of each shop item category
                self.hatsCount = hatsData.count
                self.racecarsCount = racecarsData.count
                self.racersCount = racersData.count
                
                // extract data from each shop item category
                self.getData(data: hatsData)
                self.getData(data: racecarsData)
                self.getData(data: racersData)
                
                self.shopGrid.reloadData()
                self.shopGrid.isHidden = false
            }
        }
        
    }
    
    // extract data from each item of data
    func getData(data: [Any]) {
        for i in 0...data.count - 1 {
            let item = data[i] as! [String: Any]
            self.shopItems.append(
                Item(cost: item["cost"] as! Int,
                    name: item["name"] as! String)
            )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewCell
        cell.layer.borderColor = UIColor.systemGray.cgColor
        cell.contentView.backgroundColor = UIColor(red: 199/256, green: 199/256, blue: 204/256, alpha: 1)
        cell.isSelected = true
        // TODO: check amount of money and check price of item clicked - if not enough money - create alert saying not enough money
        
        let confirmPurchaseAlert = UIAlertController(title: "Confirm Purchase", message: "Are you sure you want to purchase this item?", preferredStyle: UIAlertController.Style.alert)
        
        confirmPurchaseAlert.addAction(UIAlertAction(title: "Buy", style: .default, handler: { (action: UIAlertAction!) in
            
            // TODO: update changes in Firestore (items bought, coins left, etc.)
            // update money label
            
        }))
        
        confirmPurchaseAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(confirmPurchaseAlert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor(red: 199/256, green: 199/256, blue: 204/256, alpha: 1).cgColor
        cell?.contentView.backgroundColor = UIColor.white
        cell?.isSelected = false
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
