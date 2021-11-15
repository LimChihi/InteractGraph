//
//  GraphView.swift
//  
//
//  Created by lim on 16/11/2021.
//

import SwiftUI

internal struct GraphView: View {
    
    private let data: Graph.NodeLayer
    
    private let edges: [Edge]
    
    @State
    private var nodeFrames: [Node.ID: CGRect] = [:]
    
    internal init(nodeLayer: Graph.NodeLayer) {
        self.data = nodeLayer
        self.edges = nodeLayer.reduce([]) { partialResult, nodes in
            partialResult + nodes.reduce([]) { edges, node in
                edges + node.outputEdge.map {
                    Edge(from: node.id, to: $0.to)
                }
            }
        }
    }
    
    internal var body: some View {
        ZStack {
            ForEach(edges) { edge in
                if let fromMode = nodeFrames[edge.from], let toNode = nodeFrames[edge.to] {
                    Path { path in
                        path.move(to: fromMode.bottomCenter)
                        path.addLine(to: toNode.topCenter)
                    }
                    .stroke(Color.green ,style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                }
            }
            LayoutGraphView(
                data: data,
                coordinateSpace: .named("GraphView"),
                rankGap: 50,
                levelGap: 50)
                .onPreferenceChange(PositionKey.self) { newValue in
                    nodeFrames = newValue
                }
            
        }
        .coordinateSpace(name: "GraphView")
        
    }
    
}

struct GraphView_Previews: PreviewProvider {
    
    static var data: Graph.NodeLayer {
        let graph = Graph()
        
        let node0 = Node(id: 0x0)
        let node1 = Node(id: 0x1)
        let node2 = Node(id: 0x2)
        let node3 = Node(id: 0x3)
        let node4 = Node(id: 0x4)

        
        let edge0 = Edge(from: node0, to: node1)
        let edge1 = Edge(from: node0, to: node2)
        let edge2 = Edge(from: node2, to: node3)
        let edge3 = Edge(from: node3, to: node4)
        let edge4 = Edge(from: node2, to: node4)

        graph.addNodes([node0, node1, node2, node3, node4])
        graph.addEdges([edge0, edge1, edge2, edge3, edge4])
        return graph.nodeLayering()
    }
    
    
    static var previews: some View {
        GraphView(nodeLayer: data)
    }
}
