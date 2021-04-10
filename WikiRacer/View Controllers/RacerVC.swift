//
//  RacerVC.swift
//  WikiRacer
//
//  Created by Tracy on 3/25/21.
//

import UIKit
import FirebaseStorage

class RacerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var hatImage: UIImageView!
    
    @IBOutlet weak var inventoryGrid: UICollectionView!
    let RACER = CURRENT_USER!.racer
    var items = [String]()
    
    var storageRef: StorageReference!
    var hatsRef: StorageReference!
    var racecarsRef: StorageReference!
    var racersRef: StorageReference!
    
    var hatsCount = 0
    var racecarsCount = 0
    var racersCount = 0
    
    var currentAccessorries: [String]!
    var currentRacecar: String!
    var currentRacer: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()
        hatsRef = storageRef.child("hats")
        racecarsRef = storageRef.child("racecars")
        racersRef = storageRef.child("racers")
        
        inventoryGrid.dataSource = self
        inventoryGrid.delegate = self
        // Do any additional setup after loading the view.
        loadUserInventory()
        loadRacer()
    }
    
    func loadUserInventory() {
        let hats = RACER.accessoriesOwned
        let racecars = RACER.racecarsOwned
        let racers = RACER.racersOwned
        currentAccessorries = RACER.currentAccessorries
        currentRacecar = RACER.currentRacecar
        currentRacer = RACER.currentRacer
        
        hatsCount = hats.count
        racecarsCount = racecars.count
        racersCount = racers.count
        
        items.append(contentsOf: hats)
        items.append(contentsOf: racecars)
        items.append(contentsOf: racers)
        inventoryGrid.reloadData()
    }
    
    func loadRacer() {
        let racecarImageRef = racecarsRef.child("\(currentRacecar!)")
        let racerImageRef = racersRef.child("\(currentRacer!)")
        
        if !currentAccessorries.isEmpty {
            let hatImageRef = hatsRef.child("\(currentAccessorries[0])")
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            hatImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print(error)
                } else {
                    let image = UIImage(data: data!)
                    self.hatImage.image = image
                }
            }
        }
        
        racecarImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                let image = UIImage(data: data!)
                self.carImage.image = image
            }
        }
        
        racerImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                let image = UIImage(data: data!)
                self.characterImage.image = image
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
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
        let item = items[index]
        
        cell.costLabel.text = "\(item)"
        
        // Create a reference to the file you want to download
        let count = index
        
        var itemImages: StorageReference
        if count < hatsCount {
            itemImages = hatsRef.child("\(item)")
        } else if count < hatsCount + racecarsCount {
            itemImages = racecarsRef.child("\(item)")
        } else {
            itemImages = racersRef.child("\(item)")
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
        
        //        if purchasedItems.contains(item.name) {
        //            cell.isUserInteractionEnabled = false
        //            cell.contentView.backgroundColor = .systemGray
        //            cell.costLabel.textColor = .white
        //        }
        cell.layer.borderWidth = 0
        return cell
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
