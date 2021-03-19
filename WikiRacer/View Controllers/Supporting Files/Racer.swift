//
//  Racer.swift
//  WikiRacer
//
//  Created by Manuel on 3/18/21.
//

import UIKit

struct Racer {

    var accessoriesOwned: [String]
    var currentAccessorries: [String]
    var currentRacer: String

    var dictionary: [String: Any] {
        return [
            "accessoriesOwned": accessoriesOwned,
            "currentAccessorries": currentAccessorries,
            "points": currentRacer
        ]
    }
}
