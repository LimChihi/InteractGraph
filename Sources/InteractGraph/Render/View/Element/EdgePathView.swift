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
            for point in controlPoints {
                path.addLine(to: point)
            }
            path.addLine(to: destination)
        }
        .stroke(Color.green ,style: StrokeStyle(lineWidth: 2, lineJoin: .round))
    }
}

struct EdgePathView_PreViews: PreviewProvider {
    
    static var previews: some View {
        EdgePathView(origin: CGPoint(x: 50, y: 50), destination: CGPoint(x: 200, y: 200), controlPoints: [])
    }
    
}
