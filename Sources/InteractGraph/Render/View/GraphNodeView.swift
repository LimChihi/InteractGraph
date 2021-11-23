//
//  GraphNodeView.swift
//  
//
//  Created by lim on 22/11/2021.
//

import SwiftUI

internal struct GraphNodeView: View {

    private let graph: AdjacencyListGraph<ViewElementGraph.LevelElement>
    
    private let coordinateSpace: CoordinateSpace
    
    private let rankGap: CGFloat
    
    private let levelGap: CGFloat
    
    internal init(graph: AdjacencyListGraph<ViewElementGraph.LevelElement>, coordinateSpace: CoordinateSpace, rankGap: CGFloat, levelGap: CGFloat) {
        self.graph = graph
        self.coordinateSpace = coordinateSpace
        self.rankGap = rankGap
        self.levelGap = levelGap
    }
    
    var body: some View {
        LazyVStack(spacing: rankGap) {
            ForEach(graph.storage.indices) { rankIndex in
                LazyHStack(spacing: levelGap) {
                    ForEach(graph[rankIndex]) { item in
                        GeometryReader { reader in
                            Group {
                                switch item.element {
                                case .node(let node):
                                    EllipseLabelView(label: "nodeInde: \(node.id)")
                                        .preference(key: ElementFramesKey.self, value: [.node(node): reader.frame(in: coordinateSpace)])
                                case .edge(let edge):
                                    Spacer()
                                        .preference(key: ElementFramesKey.self, value: [.edge(edge: edge, rank: rankIndex): reader.frame(in: coordinateSpace)])

                                }
                            }
                        }
                        .frame(width: item.frame.width, height: item.frame.height)
                    }
                }
            }
        }
    }
}

internal enum GraphNodeViewElement: Hashable {
    
    case node(Node)
    
    case edge(edge: Edge, rank: Int)
    
}

internal struct ElementFramesKey: PreferenceKey {

    typealias Value = [GraphNodeViewElement: CGRect]
    
    static let defaultValue: [GraphNodeViewElement : CGRect] = [:]
    
    static func reduce(value: inout [GraphNodeViewElement : CGRect], nextValue: () -> [GraphNodeViewElement : CGRect]) {
        value.merge(nextValue()) { $1 }
    }
    
}


extension Dictionary where Key == GraphNodeViewElement, Value == CGRect {
    
    internal func edgeFrames(_ edge: Edge) -> [CGRect] {
        compactMap { key, value -> (CGRect, Int)? in
            guard case .edge(let caseEdge, let rank) = key else {
                return nil
            }
            guard caseEdge == edge else {
                return nil
            }
            
            return (value, rank)
        }.sorted { lhs, rhs in
            lhs.1 > rhs.1
        }.map { value, _ in
            value
        }
    }
}


struct GraphNodeView_Previews: PreviewProvider {
    
    static var data: AdjacencyListGraph<ViewElementGraph.LevelElement> {
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
        
        graph.addNodes([node0, node1, node2, node3, node4, node5])
        graph.addEdges([edge0, edge1, edge2, edge3, edge4])
        
        let layoutGraph = LayoutGraph(graph)
        let viewElementGraph = ViewElementGraph(layoutGraph)
        return viewElementGraph.storage
    }
    
    static var previews: some View {
        GraphNodeView(graph: data, coordinateSpace: .local, rankGap: 50, levelGap: 50)
            .frame(width: 600, height: 600)
    }
}