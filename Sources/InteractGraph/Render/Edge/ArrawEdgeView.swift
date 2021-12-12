//
//  ArrawEdgeView.swift
//  InteractGraph
//
//  Created by limchihi on 16/11/2021.
//
//  Copyright (c) 2021 Lin Zhiyi <limchihi@foxmail.com>
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

internal struct ArrawEdgeView: View {
    
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
            EdgeLine(origin: origin, destination: destination, controlPoints: controlPoints)
            .stroke(style: StrokeStyle(lineWidth: 2, lineJoin: .round, dash: edge.dashed ? [5] : []))
            if directed {
                let origin = controlPoints.last.map {
                    CGPoint(x: controlPoints.count % 2 == 0 ? $0.x : $0.x * coefficient, y: $0.y)
                } ?? self.origin
                Arraw(origin: origin, destination: destination)
            }
        }
        .foregroundColor(edge.color)
        .drawingGroup()
    }
}


/// The size is not adjustable.
fileprivate struct EdgeLine: Shape {
    
    fileprivate let origin: CGPoint
    
    fileprivate let destination: CGPoint
    
    fileprivate let controlPoints: [CGPoint]
    
    fileprivate func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: origin)
            for index in controlPoints.indices {
                guard (2 * index + 1) < controlPoints.endIndex - 2 else {
                    break
                }
                let control = controlPoints[2 * index]
                path.addQuadCurve(
                    to: controlPoints[2 * index + 1],
                    control: CGPoint(x: control.x * coefficient, y: control.y)
                )
            }
            
            let lastControlPoint = controlPoints.last.map {
                CGPoint(x: controlPoints.count % 2 == 0 ? $0.x : $0.x * 1.4, y: $0.y)
            } ?? origin
            
            let k = destination.angleOfInclination(lastControlPoint) + ((destination.x - lastControlPoint.x) > 0 ? .pi : 0)
            let newDestination = CGPoint(
                x: cos(k) * 3 + destination.x,
                y: sin(k) * 3 + destination.y
            )
            if !controlPoints.isEmpty {
                if controlPoints.count % 2 != 0 {
                    path.addQuadCurve(
                        to: newDestination,
                        control: CGPoint(
                            x: controlPoints.last!.x * coefficient,
                            y: controlPoints.last!.y)
                    )
                } else {
                    let control1 = controlPoints[controlPoints.count - 2]
                    path.addCurve(
                        to: newDestination,
                        control1: CGPoint(x: control1.x * coefficient, y: control1.y),
                        control2: controlPoints[controlPoints.count - 1])
                }
            } else {
                path.addLine(to: newDestination)
            }
        }
    }
}


/// https://stackoverflow.com/questions/48625763/how-to-draw-a-directional-arrow-head
/// The size is not adjustable.
fileprivate struct Arraw: Shape {
    
    fileprivate let origin: CGPoint
    
    fileprivate let destination: CGPoint
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            
            let pointerLineLength: CGFloat = 12
            let arrowAngle: CGFloat = .pi / 7
            
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
    }
    
}

fileprivate let coefficient: CGFloat = 1.4

struct EdgePathView_PreViews: PreviewProvider {
    
    static var previews: some View {
        ArrawEdgeView(
            edge: .init(from: "0x0", to: "0x1", color: nil),
            directed: true,
            origin: .init(x: 200, y: 50),
            destination: .init(x: 200, y: 350),
            controlPoints: [
                .init(x: 400, y: 150),
                .init(x: 300, y: 300)
            ]
        )
    }
    
}
