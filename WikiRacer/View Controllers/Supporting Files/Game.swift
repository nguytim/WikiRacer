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
}
