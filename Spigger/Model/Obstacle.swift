//
//  Obstacle.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 05/05/23.
//

import Foundation
import SwiftUI

enum ObstacleModifier: CaseIterable {
    case Add
    case Subtract
    case Multiply
    case Divide
}

enum PowerUpType: CaseIterable {
    case Rapid
    case Spread
}

struct Obstacle: Identifiable, Equatable {
    var id = UUID().uuidString
    var modifier: ObstacleModifier
    var amount: Int
    var pos: CGPoint
    var size: CGSize = .init(width: 50, height: 50)
    var color: Color = .green
}

struct PowerUp: Identifiable, Equatable {
    var id = UUID().uuidString
    var type: PowerUpType
    var pos: CGPoint
    var size: CGSize = .init(width: 50, height: 50)
    var color: Color = .purple
}
