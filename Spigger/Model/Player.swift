//
//  Player.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 05/05/23.
//

import Foundation

struct Player: Identifiable, Equatable {
    var id = UUID().uuidString
    var health: Int = 100
    var damage: Int = 10
    var pos: CGPoint
}
