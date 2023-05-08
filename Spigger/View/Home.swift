//
//  SwiftUIView.swift
//
//
//  Created by Aaron Christopher Tanhar on 04/05/23.
//

import SwiftUI

struct Home: View {
    @AppStorage("highscore") var highScore: Int?

    @State private var isShowingGameView = false
    @State private var isShowingHowToView = false
    @State private var animateGradient = false

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Image("Logo")
                    if highScore != nil {
                        Text("High Score: \(highScore ?? 0)").font(.title).bold()
                    }
                    NavigationLink {
                        GameView()
                    } label: {
                        Label("Play", systemImage: "play.circle")
                    }.buttonStyle(MainButton(width: 200)).font(.title).padding()
                    Button {
                        isShowingHowToView = true
                    } label: {
                        Label("How to play", systemImage: "questionmark.circle")
                    }.buttonStyle(MainButton(width: 200)).font(.title).padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 1
            .background(
                LinearGradient(colors: [Color("Blue"), .yellow], startPoint: animateGradient ? .topLeading : .bottomLeading, endPoint: animateGradient ? .bottomTrailing : .topTrailing)
                    .ignoresSafeArea()
                    .hueRotation(.degrees(animateGradient ? 45 : 0))
                    .onAppear {
                        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                            animateGradient.toggle()
                        }
                    }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
