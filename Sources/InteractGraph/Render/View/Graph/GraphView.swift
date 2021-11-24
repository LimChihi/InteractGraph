//
//  GraphView.swift
//  
//
//  Created by lim on 16/11/2021.
//

import SwiftUI

public struct GraphView: View {
    
    private let graph: ViewElementGraph
    
    @State
    private var elementFrames: ElementFramesKey.Value = [:]
    
    @State
    private var edges: [Edge] = []
    
    public init(graph: Graph) {
        let layoutGraph = LayoutGraph(graph)
        let viewElementGraph = ViewElementGraph(layoutGraph)
        self.graph = viewElementGraph
    }
    
    public var body: some View {
        ZStack {

            GraphNodeView(graph: graph.storage, coordinateSpace: .named(coordinateSpaceName), rankGap: 50, levelGap: 50)
                .onPreferenceChange(ElementFramesKey.self) { newValue in
                    elementFrames = newValue
                }
            ForEach(graph.edges) { edge in
                if let origin = elementFrames[.node(Node(id: edge.from))]?.bottomCenter,
                   let destination = elementFrames[.node(Node(id: edge.to))]?.topCenter {
                    EdgePathView(origin: origin, destination: destination, controlPoints: elementFrames.edgeFrames(edge).map { $0.center})
                }
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
    
}

fileprivate let coordinateSpaceName = "com.limchihi.ZStack.Graph"

struct GraphView_Previews: PreviewProvider {
    
    static var data: Graph {
        
        let graph = Graph()
        
        
        let node0 = Node(id: 0x0)
        let node1 = Node(id: 0x1)
        let node2 = Node(id: 0x2)
        let node3 = Node(id: 0x3)
        let node4 = Node(id: 0x4)
        let node5 = Node(id: 0x5)
        
        
        let edge0 = Edge(from: node0, to: node1)
        let edge1 = Edge(from: node0, to: node2)
        let edge2 = Edge(from: node2, to: node3)
        let edge3 = Edge(from: node3, to: node4)
        let edge4 = Edge(from: node2, to: node4)
        
        let edge5 = Edge(from: node2, to: node5)
        
        graph.addNodes([node0, node1, node2, node3, node4, node5])
        graph.addEdges([edge0, edge1, edge2, edge3, edge4, edge5])
        
        return graph
    }
    
    
    static var previews: some View {
        GraphView(graph: data)
            .frame(width: 600, height: 600, alignment: .center)
    }
}
