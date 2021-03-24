//
//  Game.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import Foundation
import UIKit

class Player {
    
    var uid: String
    var name: String
    var time: String
    var numLinks: Int
    
    init(uid: String, name: String, time: String, numLinks: Int) {
        self.uid = uid
        self.name = name
        self.time = time
        self.numLinks = numLinks
    }
}

class Game {
    let startingArticle: Article
    let targetArticle: Article
    var elapsedTime: Int
    var numLinks: Int
    
    // MULTIPLAYER ATTRIBUTES
    var code: String?
    var gameType: String?
    var leaderboard: [Player]?
    
    init(startingArticle: Article, targetArticle: Article) {
        self.startingArticle = startingArticle
        self.targetArticle = targetArticle
        self.elapsedTime = 0
        self.numLinks = 0
    }
    
    init(startingArticle: Article, targetArticle: Article, code: String, gameType: String, leaderboard: [Player]) {
        self.startingArticle = startingArticle
        self.targetArticle = targetArticle
        self.elapsedTime = 0
        self.numLinks = 0
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
    return randomString(length: 10)
}

// generate random string given a length
func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}
