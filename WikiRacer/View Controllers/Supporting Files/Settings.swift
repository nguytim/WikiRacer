//
//  Settings.swift
//  WikiRacer
//
//  Created by Tim Nguyen on 4/8/21.
//

struct Settings {
    var darkModeEnabled: Bool
    var colorfulButtonsEnabled: Bool
    var soundEffectsEnabled: Bool
    var notificationsEnabled: Bool
    
    var dictionary: [String: Bool] {
        return [
            "darkModeEnabled": darkModeEnabled,
            "colorfulButtonsEnabled": colorfulButtonsEnabled,
            "soundEffectsEnabled": soundEffectsEnabled,
            "notificationsEnabled": notificationsEnabled
        ]
    }
}
