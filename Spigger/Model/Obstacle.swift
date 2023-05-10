//
//  Obstacle.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 05/05/23.
//

import Foundation

enum ObstacleModifier {
    case Add
    case Subtract
    case Multiply
    case Divide
}

struct Obstacle: Identifiable, Equatable {
    var id = UUID().uuidString
    var modifier: ObstacleModifier
    var amount: Int
    var pos: CGPoint
    var size: CGSize = .init(width: 100, height: 100)
}
