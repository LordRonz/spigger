//
//  Enemy.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 05/05/23.
//

import Foundation

struct Enemy: Identifiable, Equatable {
    var id = UUID().uuidString
    var health: Int = 10
    var damage: Int = 5
    var kamikazeDamage: Int = 20
    var pos: CGPoint
}
