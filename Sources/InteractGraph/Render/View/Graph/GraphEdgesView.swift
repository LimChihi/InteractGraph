//
//  GraphEdgesView.swift
//  InteractGraph
//
//  Created by lim on 25/11/2021.
//

import SwiftUI

internal struct GraphEdgesView: View {
    
    @Environment(\.graph)
    private var graph: Graph

    private let elementFrames: ElementFramesKey.Value
    
    internal init(elementFrames: ElementFramesKey.Value) {
        self.elementFrames = elementFrames
    }
    
    internal var body: some View {
        ForEach(graph.allEdges) { edge in
            if let originNode = elementFrames[.node(edge.fromNodeIndex)],
               let destinationNode = elementFrames[.node(edge.toNodeIndex)] {
                let isTopDown = (originNode.minY - destinationNode.minY) < 0
                let origin = isTopDown ? originNode.bottomCenter : originNode.topCenter
                let destination = isTopDown ? destinationNode.topCenter : destinationNode.bottomCenter
                let controlPoints = elementFrames.edgeFrames(edge.index).map { isTopDown ? $0.bottomCenter : $0.topCenter }
                EdgePathView(
                    edge: graph[edge.index],
                    directed: graph.directed,
                    origin: origin,
                    destination: destination,
                    controlPoints: isTopDown ? controlPoints : controlPoints.reversed()
                )
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
