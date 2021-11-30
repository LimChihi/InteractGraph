//
//  EdgePathView.swift
//  InteractGraph
//
//  Created by limchihi on 16/11/2021.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SwiftUI

internal struct EdgePathView: View {
    
    private let edge: Edge

    private let directed: Bool
    
    private let origin: CGPoint
    
    private let destination: CGPoint
    
    private let controlPoints: [CGPoint]
    
    internal init(edge: Edge, directed: Bool, origin: CGPoint, destination: CGPoint, controlPoints: [CGPoint]) {
        self.edge = edge
        self.directed = directed
        self.origin = origin
        self.destination = destination
        self.controlPoints = controlPoints
    }
    
    internal var body: some View {
        ZStack {
            let path = Path { path in
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
            let style = StrokeStyle(lineWidth: 2, lineJoin: .round, dash: edge.dashed ? [5] : [])
            if let color = edge.color {
                path.stroke(color, style: style)
            } else {
                path.stroke(style: style)
            }
            
            if directed {
                 let arraw = Path { path in
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
                let style = StrokeStyle(lineWidth: 2, lineJoin: .round, dash: [])
                if let color = edge.color {
                    arraw.stroke(color, style: style)
                } else {
                    arraw.stroke(style: style)
                }
            }
        }
        .drawingGroup()
    }
}

struct EdgePathView_PreViews: PreviewProvider {
    
    static var previews: some View {
        EdgePathView(edge: .init(from: 0, to: 1), directed: true, origin: CGPoint(x: 50, y: 50), destination: CGPoint(x: 300, y: 300), controlPoints: [CGPoint(x: 100, y: 100), CGPoint(x: 100, y: 300)])
    }
    
}