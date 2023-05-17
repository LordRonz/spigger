//
//  GameView.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 05/05/23.
//

import SwiftUI

struct AlertItem: Identifiable {
    var id = UUID()
    var title: Text
    var message: String
    var dismissButton: Alert.Button?
}

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("highscore") var highScore: Int?
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
    @State private var obstacles: [Obstacle] = []
    @State private var powerUps: [PowerUp] = []
    @State private var elapsedMs: Double = 0
    @State private var score = 0
    @State private var player: Player = .init(pos: CGPoint(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.8))
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil // 1
    @State private var isGameOver = false
    @State private var alertItem: AlertItem?

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
            HStack {
                Text("Score: \(score)").font(.title2)
                    .padding(10).background(.ultraThinMaterial).cornerRadius(20).overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [3]))
                    )
            }
            .frame(maxHeight: .infinity, alignment: .top)
            ForEach(enemies) { enemy in
                Rectangle()
                    .frame(width: enemy.size.width, height: enemy.size.height)
                    .position(enemy.pos)
                    .foregroundColor(enemy.color.opacity(0))
                    .overlay(
                        Image(enemy.type == .Default ? "enemy-scout" : "dreadnought")
                            .resizable()
                            .scaledToFit()
                            .frame(width: enemy.size.width + (enemy.type == .Default ? 125 : 50), height: enemy.size.height + (enemy.type == .Default ? 125 : 50))
                            .position(enemy.pos)
                    )
            }
            ForEach(obstacles) { obstacle in
                Rectangle()
                    .frame(width: obstacle.size.width, height: obstacle.size.height)
                    .position(obstacle.pos)
                    .foregroundColor(obstacle.color)
                    .overlay(
                        Text("\(getSymbol(s: obstacle.modifier)) \(obstacle.amount)").position(obstacle.pos)
                    )
            }
            ForEach(powerUps) { obstacle in
                Rectangle()
                    .frame(width: obstacle.size.width, height: obstacle.size.height)
                    .position(obstacle.pos)
                    .foregroundColor(obstacle.color)
                    .overlay(
                        Text("?").font(.title).position(obstacle.pos)
                    )
            }
            ForEach(bullets) { bullet in
                Rectangle()
                    .foregroundColor(bullet.color)
                    .frame(width: bullet.size.width, height: bullet.size.height)
                    .position(bullet.pos)
                    .rotationEffect(.degrees(0))
            }
            Rectangle()
                .foregroundColor(.red.opacity(0))
                .frame(width: player.size.width, height: player.size.height)
                .position(player.pos)
                .gesture(
                    simpleDrag
                )
                .overlay(
                    Image("ship-full")
                        .resizable()
                        .scaledToFit()
                        .frame(width: player.size.width + 45, height: player.size.height + 45)
                        .position(player.pos)
                )
            if let fingerLocation = fingerLocation {
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .position(fingerLocation)
            }
            HStack {
                Text("Health: \(player.health)").font(.title2).foregroundColor(.green)
                    .padding(10).background(.ultraThinMaterial).cornerRadius(20).overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [3]))
                    )
                Text("Damage: \(player.damage)").font(.title2).foregroundColor(.red)
                    .padding(10).background(.ultraThinMaterial).cornerRadius(20).overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [3]))
                    )
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .alert(
            "Game Over",
            isPresented: $isGameOver,
            presenting: alertItem
        ) { _ in
            Button("Back to home") {
                // Handle back to home.
                dismiss()
            }
        } message: { details in
            Text(details.message)
        }
        .onReceive(gameUpdate) { _ in
            if player.health <= 0 && !isGameOver {
                if highScore != nil {
                    highScore = highScore! < score ? score : highScore
                } else {
                    highScore = score
                }
                alertItem = AlertItem(title: Text("Game Over"), message: "Your score: \(score)", dismissButton: Alert.Button.default(
                    Text("Back to home"), action: { print("") }
                ))
                isGameOver = true
                gameUpdate.upstream.connect().cancel()
            }
            let widthBound = UIScreen.main.bounds.width
            let heightBound = UIScreen.main.bounds.height
            elapsedMs += 1
            let randomInt = Int.random(in: 1 ..< 250)
            if enemies.count < 4 {
                if randomInt == 69 {
                    let randomIntBoss = Int.random(in: 1 ..< 20)
                    if randomIntBoss != 10 {
                        enemies.append(Enemy(health: Int.random(in: 50 ..< 100), pos: CGPoint(x: Int.random(in: 50 ..< Int(widthBound)), y: 0), shootTimer: elapsedMs + 1))
                    } else {
                        enemies.append(Enemy(health: 1000, kamikazeDamage: 40, pos: CGPoint(x: Int.random(in: 100 ..< Int(widthBound) - 50), y: 0), shootTimer: elapsedMs + 1, size: .init(width: 120, height: 120), type: .Dreadnought, speed: 0.5))
                    }
                }
            }
            if obstacles.count < 3 {
                if randomInt == 100 {
                    obstacles.append(Obstacle(modifier: .allCases.randomElement()!, amount: Int.random(in: 1 ... 10), pos: CGPoint(x: Int.random(in: 50 ..< Int(widthBound)), y: 0)))
                }
            }

            let randomIntPowerUp = Int.random(in: 1 ... 1000)
            if randomIntPowerUp == 69 && powerUps.count < 2 {
                powerUps.append(PowerUp(type: .allCases.randomElement()!, pos: CGPoint(x: Int.random(in: 50 ..< Int(widthBound)), y: 0)))
            }

            if elapsedMs == player.shootTimer {
                bullets.append(Bullet(owner: .Player, damage: player.damage, pos: player.pos, color: .blue))
                player.shootTimer += player.powerUp == .Rapid ? 20 : 100
                if player.powerUp == .Spread {
                    bullets.append(Bullet(owner: .Player, damage: player.damage, pos: CGPoint(x: player.pos.x + 15, y: player.pos.y), color: .blue))
                    bullets.append(Bullet(owner: .Player, damage: player.damage, pos: CGPoint(x: player.pos.x - 15, y: player.pos.y), color: .blue))
                }
            }
            if elapsedMs == player.powerUpTimeout {
                player.powerUp = .None
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
                y: enemies[index].pos.y < heightBound ? enemies[index].pos.y + enemies[index].speed : 0
            )
            if enemies[index].pos.y >= heightBound {
                idToBeRemoved.append(enemies[index].id)
            } else if checkCollision(locationA: player.pos, locationB: enemies[index].pos, sizeA: player.size, sizeB: enemies[index].size) {
                idToBeRemoved.append(enemies[index].id)
                player.health -= enemies[index].kamikazeDamage
            } else if enemies[index].health <= 0 {
                score += enemies[index].type == .Default ? 10 : 100
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
                        idToBeRemoved.append(bullet.id)
                        continue
                    }
                } else {
                    bullets[index].pos = CGPoint(
                        x: bullets[index].pos.x,
                        y: bullets[index].pos.y < heightBound ? bullets[index].pos.y - 2 : 0
                    )
                    for (indexEn, ene) in enemies.enumerated() {
                        if checkCollision(locationA: ene.pos, locationB: bullets[index].pos, sizeA: ene.size, sizeB: bullets[index].size) {
                            enemies[indexEn].health -= bullet.damage
                            idToBeRemoved.append(bullet.id)
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

            idToBeRemoved = []

            for (index, obstacle) in obstacles.enumerated() {
                obstacles[index].pos = CGPoint(
                    x: obstacle.pos.x,
                    y: obstacle.pos.y < heightBound ? obstacle.pos.y + 1.5 : 0
                )
                if checkCollision(locationA: player.pos, locationB: obstacle.pos, sizeA: player.size, sizeB: obstacle.size) {
                    switch obstacle.modifier {
                    case .Add:
                        player.damage += obstacle.amount
                    case .Subtract:
                        player.damage -= obstacle.amount
                    case .Multiply:
                        player.damage *= obstacle.amount
                    case .Divide:
                        player.damage /= obstacle.amount
                    }
                    idToBeRemoved.append(obstacle.id)
                } else if obstacle.pos.y >= heightBound {
                    idToBeRemoved.append(obstacle.id)
                }
            }

            for idToBeRemove in idToBeRemoved {
                obstacles = obstacles.filter { $0.id != idToBeRemove }
            }

            idToBeRemoved = []

            for (index, powerUp) in powerUps.enumerated() {
                powerUps[index].pos = CGPoint(
                    x: powerUp.pos.x,
                    y: powerUp.pos.y < heightBound ? powerUp.pos.y + 1.5 : 0
                )
                if checkCollision(locationA: player.pos, locationB: powerUp.pos, sizeA: player.size, sizeB: powerUp.size) {
                    switch powerUp.type {
                    case .Rapid:
                        player.powerUp = .Rapid
                    case .Spread:
                        player.powerUp = .Spread
                    }
                    player.powerUpTimeout = elapsedMs + 1000
                    idToBeRemoved.append(powerUp.id)
                } else if powerUp.pos.y >= heightBound {
                    idToBeRemoved.append(powerUp.id)
                }
            }

            for idToBeRemove in idToBeRemoved {
                powerUps = powerUps.filter { $0.id != idToBeRemove }
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

    func getSymbol(s: ObstacleModifier) -> String {
        switch s {
        case .Add:
            return "+"
        case .Subtract:
            return "-"
        case .Multiply:
            return "×"
        case .Divide:
            return "÷"
        }
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
