//
//  Bullet.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 08/05/23.
//

import Foundation
import SwiftUI

enum BulletOwner: CaseIterable {
    case Player
    case Enemy
}

enum BulletDirection: CaseIterable {
    case Up
    case Down
}

enum BulletLeanDir: CaseIterable {
    case None
    case Left
    case Right
}

struct Bullet: Identifiable {
    var id = UUID().uuidString
    var owner: BulletOwner
    var damage: Int
    var pos: CGPoint
    var color: Color = .red
    var size: CGSize = .init(width: 5, height: 25)
    var rotation = BulletLeanDir.None
    var xMov: Int = 0
}
