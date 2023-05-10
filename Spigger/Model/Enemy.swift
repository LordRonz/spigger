//
//  Enemy.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 05/05/23.
//

import Foundation
import SwiftUI

struct Enemy: Identifiable {
    var id = UUID().uuidString
    var health: Int = 20
    var damage: Int = 5
    var kamikazeDamage: Int = 20
    var pos: CGPoint
    var shootTimer: Double
    var color: Color = .blue
    var size: CGSize = .init(width: 100, height: 100)
}
