//
//  Game.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import Foundation

class Game {
    let startingArticle: String
    let targetArticle: String
    var elapsedTime: Int
    var numLinks: Int
    
    init(startingArticle: String, targetArticle: String) {
        self.startingArticle = startingArticle
        self.targetArticle = targetArticle
        self.elapsedTime = 0
        self.numLinks = 0
    }
}
