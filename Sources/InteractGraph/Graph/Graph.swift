//
//  Graph.swift
//  InteractGraph
//
//  Created by lim on 28/11/2021.
//


internal typealias NodeIndex = GraphStorage<Node, Edge>.NodeIndex

internal typealias EdgeIndex = GraphStorage<Node, Edge>.EdgeIndex

internal typealias InputEdge = NodeIndex

internal typealias OutputEdge = NodeIndex

public struct Graph {
    
    private let storage: GraphStorage<Node, Edge>
    
    public init(directed: Bool = true) {
        self.storage = GraphStorage(directed: directed)
    }
    
    public init<SN: Sequence, SE: Sequence>(directed: Bool = true, nodes: SN, edges: SE) where SN.Element == Node, SE.Element == Edge {
        self.storage = GraphStorage(directed: directed)
        
        self.storage.add(nodes: nodes)
        self.storage.add(edges: edges)
    }
    
    internal var directed: Bool {
        storage.directed
    }
    
    internal var allEdges: [GraphEdge] {
        storage.allEdges.map { GraphEdge(index: $0.index, fromNodeIndex: $0.from, toNodeIndex: $0.to) }
    }
    
    public mutating func add(node: Node) {
        storage.add(node: node)
    }

    public mutating func add<S: Sequence>(nodes: S) where S.Element == Node {
        storage.add(nodes: nodes)
    }
    
    internal func forEach(body: (Node, [InputEdge], [OutputEdge], NodeIndex, inout Bool) -> ()) {
        storage.forEach(body: body)
    }

    internal subscript(nodeIndex: NodeIndex) -> Node {
        storage[nodeIndex]
    }

    internal mutating func remove(at nodeIndex: NodeIndex) -> Node {
        storage.remove(at: nodeIndex)
    }

    internal mutating func remove<S: Sequence>(nodesAt nodeIndices: S) -> [Node] where S.Element == NodeIndex {
        storage.remove(nodesAt: nodeIndices)
    }

    public mutating func add(edge: Edge) {
        storage.add(edge: edge)
    }

    public mutating func add<S: Sequence>(edges: S) where S.Element == Edge {
        storage.add(edges: edges)
    }
    
    internal func edgeIndex(from: NodeIndex, to: NodeIndex) -> EdgeIndex? {
        storage.edgeIndex(from: from, to: to)
    }

    internal subscript(edgeIndex: EdgeIndex) -> Edge {
        storage[edgeIndex]
    }
    
    internal func forEach(body: (Edge, EdgeIndex, inout Bool) -> ()) {
        storage.forEach(body: body)
    }
    
    internal func inputEdges(for nodeIndex: NodeIndex) -> [InputEdge] {
        storage.inputEdges(for: nodeIndex)
    }
    
    internal func outputEdges(for nodeIndex: NodeIndex) -> [OutputEdge] {
        storage.outputEdges(for: nodeIndex)
    }

    internal mutating func remove(at edgeIndex: EdgeIndex) -> Edge {
        storage.remove(at: edgeIndex)
    }

    internal mutating func remove<S: Sequence>(edgesAt edgeIndices: S) -> [Edge] where S.Element == EdgeIndex {
        storage.remove(edgesAt: edgeIndices)
    }
    
}
