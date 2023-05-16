//
//  Player.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 05/05/23.
//

import Foundation

enum PlayerPowerUp: CaseIterable {
    case Rapid
    case Spread
    case None
}

struct Player: Identifiable, Equatable {
    var id = UUID().uuidString
    var health: Int = 100
    var damage: Int = 10
    var pos: CGPoint
    var shootTimer: Double = 100
    var size: CGSize = .init(width: 80, height: 80)
    var powerUp = PlayerPowerUp.None
    var powerUpTimeout: Double = 0
}
