//
//  Game.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import Foundation
import UIKit

class Player {
    var name: String
    var time: String
    var numLinks: Int
    
    init(name: String, time: String, numLinks: Int) {
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
