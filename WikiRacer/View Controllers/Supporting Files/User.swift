//
//  User.swift
//  WikiRacer
//
//  Created by Manuel on 3/18/21.
//
import UIKit
import Firebase

struct User {

    var username: String
    var racer: String
    var points: Int
    var gamesWon: Int
    var gamesPlayed: Int
    var averageGameTime: Int
    var fastestGame: Int
    var averageNumberOfLinks: Int
    var leastNumberofLink: Int
  

    var dictionary: [String: Any] {
        return [
            "username": username,
            "racer": racer,
            "points": points,
            "gamesWon": gamesWon,
            "gamesPlayed": gamesPlayed,
            "averageGameTime": averageGameTime,
            "fastestGame": fastestGame,
            "averageNumberOfLinks": averageNumberOfLinks,
            "leastNumberofLink": leastNumberofLink
        ]
    }
}
