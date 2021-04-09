//
//  Racer.swift
//  WikiRacer
//
//  Created by Manuel on 3/18/21.
//

import UIKit

struct Racer {
    
    var accessoriesOwned: [String]
    var racecarsOwned: [String]
    var racersOwned: [String]
    
    var currentAccessorries: [String]
    var currentRacecar: String
    var currentRacer: String
    
    var dictionary: [String: Any] {
        return [
            "accessoriesOwned": accessoriesOwned,
            "racecarsOwned": racecarsOwned,
            "racersOwned": racersOwned,
            "currentAccessorries": currentAccessorries,
            "currentRacecar": currentRacecar,
            "currentRacer": currentRacer
        ]
    }
}
