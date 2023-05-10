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

    let timeBetweenShot: Double = 200

    @State private var enemyPosition: CGPoint = .zero
    @State private var collision = false
    @State private var enemies: [Enemy] = []
    @State private var bullets: [Bullet] = []
    @State private var elapsedMs: Double = 0
    @State private var player: Player = .init(pos: .zero)
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil // 1

    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? player.pos // 3
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                player.pos = newLocation
            }.updating($startLocation) { _, startLocation, _ in
                startLocation = startLocation ?? player.pos // 2
            }
    }

    var fingerDrag: some Gesture {
        DragGesture()
            .updating($fingerLocation) { value, fingerLocation, _ in
                fingerLocation = value.location
            }
    }

    var body: some View {
        ZStack {
            ForEach(enemies) { enemy in
                Rectangle()
                    .frame(width: enemy.size.width, height: enemy.size.height)
                    .position(enemy.pos)
                    .foregroundColor(enemy.color)
            }
            ForEach(bullets) { bullet in
                Rectangle()
                    .foregroundColor(bullet.color)
                    .frame(width: bullet.size.width, height: bullet.size.height)
                    .position(bullet.pos)
            }
            Rectangle()
                .foregroundColor(.pink)
                .frame(width: player.size.width, height: player.size.height)
                .position(player.pos)
                .gesture(
                    simpleDrag
                )
            if let fingerLocation = fingerLocation {
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .position(fingerLocation)
            }
        }
        .onReceive(gameUpdate) { _ in
            let widthBound = UIScreen.main.bounds.width
            let heightBound = UIScreen.main.bounds.height
            elapsedMs += 1

            if enemies.count < 4 {
                let randomInt = Int.random(in: 1 ..< 250)

                if randomInt == 69 {
                    enemies.append(Enemy(health: Int.random(in: 50 ..< 100), pos: CGPoint(x: Int.random(in: 50 ..< Int(widthBound)), y: 0), shootTimer: elapsedMs + 1))
                }
            }

            if elapsedMs == player.shootTimer {
                bullets.append(Bullet(owner: .Player, damage: player.damage, pos: player.pos, color: .blue))
                player.shootTimer += 100
            }

            for (index, enemy) in enemies.enumerated() {
                if elapsedMs == enemy.shootTimer {
                    bullets.append(Bullet(owner: .Enemy, damage: 10, pos: enemy.pos))
                    enemies[index].shootTimer += timeBetweenShot
                }
            }

            var idToBeRemoved: [String] = []
            for (index, _) in enemies.enumerated() { enemies[index].pos = CGPoint(
                x: enemies[index].pos.x,
                y: enemies[index].pos.y < heightBound ? enemies[index].pos.y + 1 : 0
            )
            if enemies[index].pos.y >= heightBound {
                idToBeRemoved.append(enemies[index].id)
            } else if checkCollision(locationA: player.pos, locationB: enemies[index].pos, sizeA: player.size, sizeB: enemies[index].size) {
                idToBeRemoved.append(enemies[index].id)
                player.health -= enemies[index].kamikazeDamage
            } else if enemies[index].health <= 0 {
                idToBeRemoved.append(enemies[index].id)
            }
            }

            for idToBeRemove in idToBeRemoved {
                enemies = enemies.filter { $0.id != idToBeRemove }
            }

            idToBeRemoved = []

            for (index, bullet) in bullets.enumerated() {
                if bullets[index].owner == .Enemy {
                    bullets[index].pos = CGPoint(
                        x: bullets[index].pos.x,
                        y: bullets[index].pos.y < heightBound ? bullets[index].pos.y + 2 : 0
                    )
                    if checkCollision(locationA: player.pos, locationB: bullets[index].pos, sizeA: player.size, sizeB: bullets[index].size) {
                        player.health -= bullet.damage
                    }
                } else {
                    bullets[index].pos = CGPoint(
                        x: bullets[index].pos.x,
                        y: bullets[index].pos.y < heightBound ? bullets[index].pos.y - 2 : 0
                    )
                    for (indexEn, ene) in enemies.enumerated() {
                        if checkCollision(locationA: ene.pos, locationB: bullets[index].pos, sizeA: ene.size, sizeB: bullets[index].size) {
                            enemies[indexEn].health -= 1
                        }
                    }
                }
                if bullets[index].pos.y >= heightBound || bullets[index].pos.y < 0 {
                    idToBeRemoved.append(bullets[index].id)
                }
            }

            for idToBeRemove in idToBeRemoved {
                bullets = bullets.filter { $0.id != idToBeRemove }
            }
        }.onAppear {}
        .background(Color(UIColor.systemBackground))
        .gesture(
            simpleDrag.simultaneously(with: fingerDrag)
        )
    }

    func checkCollision(locationA: CGPoint, locationB: CGPoint, sizeA: CGSize, sizeB: CGSize) -> Bool {
        return abs(locationA.x - locationB.x) < (sizeA.width + sizeB.width) / 2 && abs(locationA.y - locationB.y) < (sizeA.height + sizeB.height) / 2
    }

    func generateEnemies() -> [Enemy] {
        return [
            Enemy(health: 50, pos: CGPoint(x: 100, y: 0), shootTimer: 0),
            Enemy(health: 50, pos: CGPoint(x: 200, y: 0), shootTimer: 0),
            Enemy(health: 50, pos: CGPoint(x: 300, y: 0), shootTimer: 0),
        ]
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
