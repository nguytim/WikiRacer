//
//  User.swift
//  WikiRacer
//
//  Created by Manuel on 3/18/21.
//
import UIKit
import Firebase

var CURRENT_USER: User?

struct User {
    
    var username: String
    var usernameID: String
    var points: Int
    var stats: Stats
    var racer: Racer
    var settings: Settings
    
    var dictionary: [String: Any] {
        return [
            "username": username,
            "usernameID": usernameID,
            "points": points,
            "stats": stats.dictionary,
            "racer": racer.dictionary,
            "settings": settings.dictionary
        ]
    }
}
