//
//  GraphEdgesView.swift
//  InteractGraph
//
//  Created by limchihi on 25/11/2021.
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
