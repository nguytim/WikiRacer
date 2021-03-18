//
//  Game.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 3/7/21.
//

import Foundation
import UIKit

class Game {
    let startingArticle: Article
    let targetArticle: Article
    var elapsedTime: Int
    var numLinks: Int
    
    init(startingArticle: Article, targetArticle: Article) {
        self.startingArticle = startingArticle
        self.targetArticle = targetArticle
        self.elapsedTime = 0
        self.numLinks = 0
    }
}
