//
//  Bullet.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 08/05/23.
//

import Foundation

enum BulletOwner {
    case Player
    case Enemy
}

struct Bullet: Identifiable, Equatable {
    var id = UUID().uuidString
    var owner: BulletOwner
    var damage: Int
    var pos: CGPoint
}
