//
//  Triangle.swift
//  Spigger
//
//  Created by Aaron Christopher Tanhar on 11/05/23.
//

import SwiftUI

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

struct TriangleView: View {
    var body: some View {
        Triangle()
            .fill(.red)
            .frame(width: 100, height: 300)
    }
}

struct Triangle_Previews: PreviewProvider {
    static var previews: some View {
        TriangleView()
    }
}
