//
//  Stats.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 4/8/21.
//

struct Stats {
    var gamesPlayed: Int
    var gamesWon: Int
    var totalGameTime: Int
    var totalNumberOfLinks: Int
    var fastestGame: Int
    var leastNumberOfLinks: Int
    
    var dictionary: [String: Int] {
        return [
            "gamesPlayed": gamesPlayed,
            "gamesWon": gamesWon,
            "totalGameTime": totalGameTime,
            "totalNumberOfLinks": totalNumberOfLinks,
            "fastestGame": fastestGame,
            "leastNumberOfLinks": leastNumberOfLinks,
        ]
    }
}
