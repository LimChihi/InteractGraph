//
//  EdgePathView.swift
//  
//
//  Created by lim on 16/11/2021.
//

import SwiftUI

internal struct EdgePathView: View {
    
    private let origin: CGPoint
    
    private let destination: CGPoint
    
    private let controlPoints: [CGPoint]
    
    internal init(origin: CGPoint, destination: CGPoint, controlPoints: [CGPoint]) {
        self.origin = origin
        self.destination = destination
        self.controlPoints = controlPoints
    }
    
    internal var body: some View {
        Path { path in
            path.move(to: origin)
            let points = (destination.y > origin.y ? controlPoints : controlPoints.reversed())
            
            for index in points.indices {
                guard (2 * index + 1) < points.endIndex else {
                    break
                }
                path.addQuadCurve(to: points[2 * index + 1], control: points[2 * index])
            }
            if points.count % 2 != 0 {
                path.addQuadCurve(to: destination, control: points.last!)
            }
            
            path.addLine(to: destination)
            
            // Arraw
            // https://stackoverflow.com/questions/48625763/how-to-draw-a-directional-arrow-head
            
            let origin = points.last ?? self.origin
            
            let pointerLineLength: CGFloat = 10
            let arrowAngle =  (Double.pi / 6)
            
            let startEndAngle = atan((destination.y - origin.y) / (destination.x - origin.x)) + ((destination.x - origin.x) < 0 ? CGFloat(Double.pi) : 0)
            let arrowLine1 = CGPoint(x: destination.x + pointerLineLength * cos(.pi - startEndAngle + arrowAngle), y: destination.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
            let arrowLine2 = CGPoint(x: destination.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle), y: destination.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))
            
            path.move(to: arrowLine1)
            path.addLine(to: destination)
            path.addLine(to: arrowLine2)
        }
        .stroke(Color.green ,style: StrokeStyle(lineWidth: 2, lineJoin: .round))
        .drawingGroup()
    }
}

struct EdgePathView_PreViews: PreviewProvider {
    
    static var previews: some View {
        EdgePathView(origin: CGPoint(x: 50, y: 50), destination: CGPoint(x: 300, y: 300), controlPoints: [CGPoint(x: 100, y: 100), CGPoint(x: 100, y: 300)])
    }
    
}
