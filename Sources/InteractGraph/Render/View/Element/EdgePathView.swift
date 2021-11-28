//
//  EdgePathView.swift
//  
//
//  Created by lim on 16/11/2021.
//

import SwiftUI

internal struct EdgePathView: View {
    
    private let directed: Bool
    
    private let attribute: Edge.Attribute
    
    private let origin: CGPoint
    
    private let destination: CGPoint
    
    private let controlPoints: [CGPoint]
    
    internal init(directed: Bool, attribute: Edge.Attribute, origin: CGPoint, destination: CGPoint, controlPoints: [CGPoint]) {
        self.directed = directed
        self.attribute = attribute
        self.origin = origin
        self.destination = destination
        self.controlPoints = controlPoints
    }
    
    internal var body: some View {
        ZStack {
            Path { path in
                path.move(to: origin)
                for index in controlPoints.indices {
                    guard (2 * index + 1) < controlPoints.endIndex else {
                        break
                    }
                    path.addQuadCurve(to: controlPoints[2 * index + 1], control: controlPoints[2 * index])
                }
                if controlPoints.count % 2 != 0 {
                    path.addQuadCurve(to: destination, control: controlPoints.last!)
                }
                
                path.addLine(to: destination)
                
            }
            .stroke(style: StrokeStyle(lineWidth: 2, lineJoin: .round, dash: []))
            if directed {
                Path { path in
                    // Arraw
                    // https://stackoverflow.com/questions/48625763/how-to-draw-a-directional-arrow-head
                    let origin = controlPoints.last ?? self.origin
                    
                    let pointerLineLength: CGFloat = 10
                    let arrowAngle =  (CGFloat.pi / 6)
                    
                    let startEndAngle = destination.angleOfInclination(origin) + ((destination.x - origin.x) < 0 ? .pi : 0)
                    
                    let angle1 = .pi - startEndAngle + arrowAngle
                    let arrowLine1 = CGPoint(
                        x: destination.x + pointerLineLength * cos(angle1),
                        y: destination.y - pointerLineLength * sin(angle1)
                    )
                    
                    let angle2 = .pi - startEndAngle - arrowAngle
                    let arrowLine2 = CGPoint(
                        x: destination.x + pointerLineLength * cos(angle2),
                        y: destination.y - pointerLineLength * sin(angle2)
                    )
                    
                    path.move(to: arrowLine1)
                    path.addLine(to: destination)
                    path.addLine(to: arrowLine2)
                }
                .stroke(style: StrokeStyle(lineWidth: 2, lineJoin: .round, dash: []))
            }
        }
        .drawingGroup()
    }
}

struct EdgePathView_PreViews: PreviewProvider {
    
    static var previews: some View {
        EdgePathView(directed: false, attribute: .init(color: nil), origin: CGPoint(x: 50, y: 50), destination: CGPoint(x: 300, y: 300), controlPoints: [CGPoint(x: 100, y: 100), CGPoint(x: 100, y: 300)])
    }
    
}
