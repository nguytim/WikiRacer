//
//  Game.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import Foundation
import UIKit

class Player: Comparable {
    
    var uid: String
    var name: String
    var time: Int
    var numLinks: Int
    
    var timeTrial: Bool = true
    
    init(uid: String, name: String, time: Int, numLinks: Int) {
        self.uid = uid
        self.name = name
        self.time = time
        self.numLinks = numLinks
    }
    
    static func < (lhs: Player, rhs: Player) -> Bool {
        if lhs.timeTrial && rhs.timeTrial {
            if lhs.time == -1 {
                return false
            } else if rhs.time == -1 {
                return true
            }
            return lhs.time < rhs.time
        }
        if lhs.numLinks == -1 {
            return false
        } else if rhs.numLinks == -1 {
            return true
        }
        return lhs.numLinks < rhs.numLinks
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        if lhs.timeTrial && rhs.timeTrial {
            return lhs.time == rhs.time
        }
        return lhs.numLinks == rhs.numLinks
    }
}

class Game {
    let startingArticle: Article
    let targetArticle: Article
    var elapsedTime: Int
    var numLinks: Int
    
    // MULTIPLAYER ATTRIBUTES
    var ownerUID: String?
    var code: String?
    var gameType: String?
    var leaderboard: [Player]?
    var hasPlayed: Bool?
    
    init(startingArticle: Article, targetArticle: Article) {
        self.startingArticle = startingArticle
        self.targetArticle = targetArticle
        self.elapsedTime = 0
        self.numLinks = 0
    }
    
    init(startingArticle: Article, targetArticle: Article, ownerUID: String, code: String, gameType: String, leaderboard: [Player]) {
        self.startingArticle = startingArticle
        self.targetArticle = targetArticle
        self.elapsedTime = 0
        self.numLinks = 0
        self.ownerUID = ownerUID
        self.code = code
        self.gameType = gameType
        self.leaderboard = leaderboard
    }
    
    func leaderboardToStringArray() -> [[String: Any]] {
        var firebaseLeaderboard = [[String: Any]]()
        
        for player in leaderboard! {
            let playerData = ["uid": player.uid,
                              "name": player.name,
                              "time": player.time,
                              "links": player.numLinks] as [String : Any]
            firebaseLeaderboard.append(playerData)
        }
        return firebaseLeaderboard
    }
    
    var dictionary: [String: Any] {
        return [
            "gameType": gameType!,
            "ownerUID": ownerUID!,
            "leaderboard": leaderboardToStringArray(),
            "startingArticleTitle": startingArticle.title,
            "startingArticleURL": startingArticle.lastPathComponentURL,
            "targetArticleTitle": targetArticle.title,
            "targetArticleURL": targetArticle.lastPathComponentURL
        ]
    }
}

// get random code for multiplayer
func getRandomCode() -> String {
    return randomString(length: 7)
}

// generate random string given a length
func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}
