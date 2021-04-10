//
//  RacerVC.swift
//  WikiRacer
//
//  Created by Tracy on 3/25/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class RacerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var hatImage: UIImageView!
    
    @IBOutlet weak var inventoryGrid: UICollectionView!
    var items = [String]()
    var equippedItems = [String]()
    
    var db: Firestore!
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
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storageRef = Storage.storage().reference()
        hatsRef = storageRef.child("hats")
        racecarsRef = storageRef.child("racecars")
        racersRef = storageRef.child("racers")
        
        inventoryGrid.dataSource = self
        inventoryGrid.delegate = self
        // Do any additional setup after loading the view.
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
        
        self.hatImage.center.y -= self.view.bounds.height
        self.characterImage.center.x -= self.view.bounds.width
        self.carImage.center.x += self.view.bounds.width
        
        UIView.animate(withDuration: 1.0, delay: 0.5,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.2,
                       options: [],
                       animations: {
                        self.hatImage.center.y += self.view.bounds.height
                        self.characterImage.center.x += self.view.bounds.width
                        self.carImage.center.x -= self.view.bounds.width
                       },
                       completion: nil)
        loadUserInventory()
        loadRacer()
    }
    
    func loadUserInventory() {
        let hats = CURRENT_USER!.racer.accessoriesOwned
        let racecars = CURRENT_USER!.racer.racecarsOwned
        let racers = CURRENT_USER!.racer.racersOwned
        
        setEquippedItems()
        
        hatsCount = hats.count
        racecarsCount = racecars.count
        racersCount = racers.count
        
        items = [String]()
        items.append(contentsOf: hats)
        items.append(contentsOf: racecars)
        items.append(contentsOf: racers)
        inventoryGrid.reloadData()
    }
    
    func setEquippedItems() {
        currentAccessorries = CURRENT_USER!.racer.currentAccessorries
        currentRacecar = CURRENT_USER!.racer.currentRacecar
        currentRacer = CURRENT_USER!.racer.currentRacer
        
        equippedItems = [String]()
        if !currentAccessorries.isEmpty {
            equippedItems.append(currentAccessorries[0])
        }
        equippedItems.append(currentRacecar)
        equippedItems.append(currentRacer)
    }
    
    func loadRacer() {
        loadHat()
        loadRacecar()
        loadCharacter()
    }
    
    func loadHat() {
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
                    self.hatImage.center.y -= self.view.bounds.height
                    
                    UIView.animate(withDuration: 1.0, delay: 0.5,
                                   usingSpringWithDamping: 0.3,
                                   initialSpringVelocity: 0.2,
                                   options: [],
                                   animations: {
                                    self.hatImage.center.y += self.view.bounds.height
                                   },
                                   completion: nil)
                }
            }
        }
    }
    
    func loadRacecar() {
        let racecarImageRef = racecarsRef.child("\(currentRacecar!)")
        racecarImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                let image = UIImage(data: data!)
                self.carImage.image = image
                self.carImage.center.x += self.view.bounds.width
                
                UIView.animate(withDuration: 1.0, delay: 0.5,
                               usingSpringWithDamping: 0.3,
                               initialSpringVelocity: 0.2,
                               options: [],
                               animations: {
                                self.carImage.center.x -= self.view.bounds.width
                               },
                               completion: nil)
            }
        }
    }
    
    func loadCharacter() {
        let characterImageRef = racersRef.child("\(currentRacer!)")
        characterImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
            } else {
                let image = UIImage(data: data!)
                self.characterImage.image = image
                self.characterImage.center.x -= self.view.bounds.width
                
                UIView.animate(withDuration: 1.0, delay: 0.5,
                               usingSpringWithDamping: 0.3,
                               initialSpringVelocity: 0.2,
                               options: [],
                               animations: {
                                self.characterImage.center.x += self.view.bounds.width
                               },
                               completion: nil)
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
        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        let index = indexPath.row
        let item = items[index]
        
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
        
        if equippedItems.contains(item) {
            cell.isUserInteractionEnabled = false
            cell.contentView.backgroundColor = .systemGray
            cell.costLabel.textColor = .white
            cell.costLabel.text = "Equipped"
        } else {
            cell.isUserInteractionEnabled = true
            cell.costLabel.text = ""
        }
        
        cell.layer.borderWidth = 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 5
        cell?.layer.borderColor = UIColor(named: "MainAquaColor")?.cgColor
        cell?.isSelected = true
        
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                var racer = data!["racer"] as! Dictionary<String, Any>
                
                let count = indexPath.row
                let item = self.items[indexPath.row]
                
                // find which category this item belongs in
                if count < self.hatsCount {
                    racer["currentAccessorries"] = [item]
                    CURRENT_USER!.racer.currentAccessorries = [item]
                    self.setEquippedItems()
                    self.loadHat()
                } else if count < self.hatsCount + self.racecarsCount {
                    racer["currentRacecar"] = item
                    CURRENT_USER!.racer.currentRacecar = item
                    self.setEquippedItems()
                    self.loadRacecar()
                } else {
                    racer["currentRacer"] = item
                    CURRENT_USER!.racer.currentRacer = item
                    self.setEquippedItems()
                    self.loadCharacter()
                }
                docRef.updateData(["racer": racer])
                self.inventoryGrid.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
        cell?.isSelected = false
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
