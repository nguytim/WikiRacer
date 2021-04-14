//
//  Settings.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 4/8/21.
//

struct Settings {
    var darkModeEnabled: Bool
    var gameplayButtonColor: Int
    var soundEffectsEnabled: Bool
    var notificationsEnabled: Bool
    
    var dictionary: [String: Any] {
        return [
            "darkModeEnabled": darkModeEnabled,
            "gameplayButtonColor": gameplayButtonColor,
            "soundEffectsEnabled": soundEffectsEnabled,
            "notificationsEnabled": notificationsEnabled
        ]
    }
}
