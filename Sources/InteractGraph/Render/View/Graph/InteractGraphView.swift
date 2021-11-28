//
//  InteractGraphView.swift
//  InteractGraph
//
//  Created by lim on 26/11/2021.
//

import SwiftUI

public struct InteractGraphView: View {
    
    @State
    private var viewGraph: ViewElementGraph
    
    public init(graph: Graph) {
        self.viewGraph = ViewElementGraph(graph)
    }
    
    public var body: some View {
        GraphView(viewGraph: viewGraph.storage) { item in
            guard case let .node(nodeIndex) = item.element else {
                return
            }
            withAnimation {
                viewGraph.setFocusNode(nodeIndex)
            }
        }
        .environment(\._graph, viewGraph.raw)
        .background()
        .onTapGesture {
            withAnimation {
                viewGraph.removeFocusNode()
            }
        }
    }
}


fileprivate struct GraphKey: EnvironmentKey {
    
    typealias Value = Graph
    
    static var defaultValue: Graph {
        Graph()
    }
}

extension EnvironmentValues {
    
    internal var graph: Graph {
        self[GraphKey.self]
    }
    
    #if DEBUG
    internal var _graph: Graph {
        get {
            self[GraphKey.self]
        }
        set {
            self[GraphKey.self] = newValue
        }
    }
    #else
    fileprivate var _graph: GraphNew {
        get {
            self[GraphKey.self]
        }
        set {
            self[GraphKey.self] = newValue
        }
    }
    #endif
    
}

internal var test_data_graph: Graph {
    let node0 = Node(id: 0x0, label: "nodeIndex: 0x0")
    let node1 = Node(id: 0x1, label: "nodeIndex: 0x1")
    let node2 = Node(id: 0x2, label: "nodeIndex: 0x2")
    let node3 = Node(id: 0x3, label: "nodeIndex: 0x3")
    let node4 = Node(id: 0x4, label: "nodeIndex: 0x4")
    let node5 = Node(id: 0x5, label: "nodeIndex: 0x5")
    
    let edge0 = Edge(from: node0.id, to: node1.id)
    let edge1 = Edge(from: node0.id, to: node2.id)
    let edge2 = Edge(from: node2.id, to: node3.id)
    let edge3 = Edge(from: node3.id, to: node4.id)
    let edge4 = Edge(from: node2.id, to: node4.id)
    
    return Graph(
        nodes: [node0, node1, node2, node3, node4, node5],
        edges: [edge0, edge1, edge2, edge3, edge4]
    )
}


struct InteractGraphView_Previews: PreviewProvider {
    static var previews: some View {
        InteractGraphView(graph: test_data_graph)
            .frame(width: 600, height: 600)
    }
}
