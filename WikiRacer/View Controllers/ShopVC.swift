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

class ShopVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let animationDuration: Double = 0.5
    let delayBase: Double = 0.3
    
    var db: Firestore!
    var storageRef: StorageReference!
    var hatsRef: StorageReference!
    var racecarsRef: StorageReference!
    var racersRef: StorageReference!
    
    var shopItems = [Item]()
    var hatsCount = 0
    var racecarsCount = 0
    var racersCount = 0
    
    var currentPoints = 0
    var purchasedItems = [String]()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if CURRENT_USER!.settings.darkModeEnabled {
            // adopt a light interface style
            overrideUserInterfaceStyle = .dark
        } else {
            // adopt a dark interface style
            overrideUserInterfaceStyle = .light
        }
        
        if Auth.auth().currentUser != nil {
            
            let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    let points:Int = data?["points"] as! Int
                    self.currentPoints = points
                    self.moneyLabel.text = "\(points) ⚡️"
                    
                    let racer = data!["racer"] as! Dictionary<String, Any>
                    let accessoriesOwned = racer["accessoriesOwned"] as! [String]
                    let racecarsOwned = racer["racecarsOwned"] as! [String]
                    let racersOwned = racer["racersOwned"] as! [String]
                    
                    self.purchasedItems.append(contentsOf: accessoriesOwned)
                    self.purchasedItems.append(contentsOf: racecarsOwned)
                    self.purchasedItems.append(contentsOf: racersOwned)
                }
            }
            shopGrid.reloadData()
        } else {
            self.moneyLabel.font = self.moneyLabel.font.withSize(25)
            self.moneyLabel.text = "Sign Up/Log In to earn ⚡️"
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.moneyLabel.center.x += self.view.bounds.width
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.moneyLabel.center.x -= self.view.bounds.width
        })
        self.shopGrid.indexPathsForSelectedItems?.forEach({ self.shopGrid.deselectItem(at: $0, animated: false) })
    }
    
    func collectionView(_ collectionView:  UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionCell
        cell.layer.cornerRadius = 10
        cell.isOpaque = true
        cell.contentView.backgroundColor = .systemGray3
        cell.contentView.isOpaque = true
        cell.alpha = 0
        cell.contentView.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        let index = indexPath.row
        let item = shopItems[index]
        
        cell.costLabel.text = "\(item.cost) ⚡️"
        
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
        
        if purchasedItems.contains(item.name) {
            cell.isUserInteractionEnabled = false
            cell.contentView.backgroundColor = .systemGray
            cell.costLabel.textColor = .white
        } else {
            cell.isUserInteractionEnabled = true
        }
        
        cell.layer.borderWidth = 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.size.width
        // Cell is 30% of your controllers view
        return CGSize(width: width * 0.3, height: width * 0.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let column = Double(cell.frame.minX / cell.frame.width)
        let row = Double(cell.frame.minY / cell.frame.height)
        let distance = sqrt(pow(column, 2) + pow(row, 2))
        let delay = sqrt(distance) * delayBase
        
        UIView.animate(withDuration: animationDuration, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [], animations: {
            cell.alpha = 1
            cell.contentView.alpha = 1
            cell.transform = .identity
        })
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
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 5
        cell?.layer.borderColor = UIColor(named: "MainAquaColor")?.cgColor
        cell?.isSelected = true
    
        let currItem = shopItems[indexPath.row]
        if Auth.auth().currentUser == nil {
            let noAccountAlert = UIAlertController(title: "No Account Connected", message: "Sign up for an account or log in to earn and use ⚡️ points on items.", preferredStyle: UIAlertController.Style.alert)
            noAccountAlert.addAction(UIAlertAction(
                                        title: "OK",
                                        style: .destructive,
                                        handler: nil))
            present(noAccountAlert, animated: true, completion: nil)
            
        } else {
            if (currItem.cost > currentPoints) {
                let insufficientMoneyAlert = UIAlertController(title: "Not Enough Fuel Points", message: "You do not have enough ⚡️ points to purchase this item.", preferredStyle: UIAlertController.Style.alert)
                insufficientMoneyAlert.addAction(UIAlertAction(
                                                    title: "OK",
                                                    style: .destructive,
                                                    handler: nil))
                present(insufficientMoneyAlert, animated: true, completion: nil)
            } else {
                
                let confirmPurchaseAlert = UIAlertController(title: "Confirm Purchase", message: "Are you sure you want to purchase this item?", preferredStyle: UIAlertController.Style.alert)
                
                confirmPurchaseAlert.addAction(UIAlertAction(title: "Buy", style: .default, handler: { (action: UIAlertAction!) in
                    
                    let docRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)
                    
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            
                            let pointsLeft = self.currentPoints - self.shopItems[indexPath.row].cost
                            self.currentPoints = pointsLeft
                            
                            var racer = data!["racer"] as! Dictionary<String, Any>
                            
                            let count = indexPath.row
                            let item = currItem.name
                            
                            self.purchasedItems.append(item)
                            
                            // find which category this item belongs in
                            if count < self.hatsCount {
                                var accessoriesOwned = racer["accessoriesOwned"] as! [String]
                                accessoriesOwned.append(item)
                                racer["accessoriesOwned"] = accessoriesOwned
                                CURRENT_USER!.racer.accessoriesOwned = accessoriesOwned
                            } else if count < self.hatsCount + self.racecarsCount {
                                var racecarsOwned = racer["racecarsOwned"] as! [String]
                                racecarsOwned.append(item)
                                racer["racecarsOwned"] = racecarsOwned
                                CURRENT_USER!.racer.racecarsOwned = racecarsOwned
                            } else {
                                var racersOwned = racer["racersOwned"] as! [String]
                                racersOwned.append(item)
                                racer["racersOwned"] = racersOwned
                                CURRENT_USER!.racer.racersOwned = racersOwned
                            }
                            
                            docRef.updateData(["racer": racer, "points": pointsLeft])
                            self.moneyLabel.text = "\(pointsLeft) ⚡️"
                            self.shopGrid.reloadData()
                        }
                    }
                }))
                
                confirmPurchaseAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                present(confirmPurchaseAlert, animated: true, completion: nil)}
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
        cell?.isSelected = false
    }
    
}
