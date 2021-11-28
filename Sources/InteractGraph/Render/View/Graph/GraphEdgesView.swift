//
//  GraphEdgesView.swift
//  
//
//  Created by lim on 25/11/2021.
//

import SwiftUI

internal struct GraphEdgesView: View {

    private let edges: [Edge]

    // FIXME: It should be [ID: CGRect]
    // Not [Element: CGRect]
    private let elementFrames: ElementFramesKey.Value
    
    internal init(edges: [Edge], elementFrames: ElementFramesKey.Value) {
        self.edges = edges
        self.elementFrames = elementFrames
    }
    
    internal var body: some View {
        ForEach(edges) { edge in
            if let originNode = elementFrames[.node(Node(id: edge.from))],
               let destinationNode = elementFrames[.node(Node(id: edge.to))] {
                let isTopDown = (originNode.minY - destinationNode.minY) < 0
                let origin = isTopDown ? originNode.bottomCenter : originNode.topCenter
                let destination = isTopDown ? destinationNode.topCenter : destinationNode.bottomCenter
                let controlPoints = elementFrames.edgeFrames(edge).map { isTopDown ? $0.bottomCenter : $0.topCenter }
                EdgePathView(
                    directed: edge.directed,
                    attribute: edge.attribute,
                    origin: origin,
                    destination: destination,
                    controlPoints: isTopDown ? controlPoints : controlPoints.reversed())
            }
        }
    }
}

struct GraphEdgesView_Previews: PreviewProvider {
    static var previews: some View {
        Text("123")
//        GraphEdgesView()
    }
}
