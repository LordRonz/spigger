//
//  GameView.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 05/05/23.
//

import SwiftUI

struct GameView: View {
    let gameUpdate = Timer.publish(
        every: 0.01, // Second
        tolerance: 0.01, // Gives tolerance so that SwiftUI makes optimization
        on: .main, // Main Thread
        in: .common // Common Loop
    ).autoconnect()

    @State private var enemyPosition: CGPoint = .zero
    @State private var collision = false
    @State private var playerLocation: CGPoint = .zero
    @State private var enemies: [Enemy] = []
    @State private var bullets: [Bullet] = []
    @State private var enemyShootTimers: [Timer] = []

    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                playerLocation = value.location
                checkCollision(locationA: playerLocation, locationB: enemyPosition, size: CGSize(width: 100, height: 100))
            }
    }

    var body: some View {
        ZStack {
            ForEach(enemies) { enemy in
                Rectangle()
                    .frame(width: 100, height: 100)
                    .position(enemy.pos)
            }
            ForEach(bullets) { bullet in
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 5, height: 25)
                    .position(bullet.pos)
            }
            Rectangle()
                .foregroundColor(.pink)
                .frame(width: 100, height: 100)
                .position(playerLocation)
                .gesture(
                    simpleDrag
                )
        }.onReceive(gameUpdate) { _ in
            let widthBound = UIScreen.main.bounds.width
            let heightBound = UIScreen.main.bounds.height

            if enemies.count < 4 {
                let randomInt = Int.random(in: 1 ..< 250)

                if randomInt == 69 {
                    enemies.append(Enemy(health: Int.random(in: 50 ..< 100), pos: CGPoint(x: Int.random(in: 50 ..< Int(widthBound)), y: 0)))
                }
            }

            var idToBeRemoved: [String] = []
            for (index, _) in enemies.enumerated() { enemies[index].pos = CGPoint(
                x: enemies[index].pos.x,
                y: enemies[index].pos.y < heightBound ? enemies[index].pos.y + 1 : 0
            )
            if enemies[index].pos.y >= heightBound {
                idToBeRemoved.append(enemies[index].id)
            }
            }

            for idToBeRemove in idToBeRemoved {
                enemies = enemies.filter { $0.id != idToBeRemove }
            }

            idToBeRemoved = []

            for (index, _) in bullets.enumerated() { bullets[index].pos = CGPoint(
                x: bullets[index].pos.x,
                y: bullets[index].pos.y < heightBound ? bullets[index].pos.y + 2 : 0
            )
            if bullets[index].pos.y >= heightBound {
                idToBeRemoved.append(bullets[index].id)
            }
            }

            for idToBeRemove in idToBeRemoved {
                bullets = bullets.filter { $0.id != idToBeRemove }
            }
        }.onAppear {}
    }

    func checkCollision(locationA: CGPoint, locationB: CGPoint, size _: CGSize) {
        if abs(locationA.x - locationB.x) < 100 && abs(locationA.y - locationB.y) < 100 {
            collision = true
        } else {
            collision = false
        }
    }

    func generateEnemies() -> [Enemy] {
        return [
            Enemy(health: 50, pos: CGPoint(x: 100, y: 0)),
            Enemy(health: 50, pos: CGPoint(x: 200, y: 0)),
            Enemy(health: 50, pos: CGPoint(x: 300, y: 0)),
        ]
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
