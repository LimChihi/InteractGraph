//
//  Graph.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//

import Foundation

public final class Graph {
    
    internal let id: UUID
    
    private let directed: Bool
    
    private let strict: Bool
    
    private var subgraphs: [Subgraph]
    
    internal private(set) var nodes: [Node]
    
    private var isArchiving: Bool
    
    
    /// Creates a graph.
    ///
    /// `directed` and `strict` is not ready yep.
    /// `directed` will always true
    /// `strict` will always false
    ///
    /// - Parameters:
    ///   - directed: Whether the graph is directed; `true by default`.
    ///   - strict: Whether the graph is strict; `false` by default.
    internal init(directed: Bool = true, strict: Bool = false) {
        self.id = UUID()
        self.directed = directed
        self.strict = strict
        self.subgraphs = []
        self.nodes = []
        self.isArchiving = false
    }
    
    public init() {
        self.id = UUID()
        self.directed = true
        self.strict = false
        self.subgraphs = []
        self.nodes = []
        self.isArchiving = false
    }
    
    private init(deepCopy instance: Graph) {
        self.id = instance.id
        self.directed = instance.directed
        self.strict = instance.strict
        self.subgraphs = instance.subgraphs
        self.nodes = instance.nodes
        self.isArchiving = instance.isArchiving
    }
    
    // MARK: - Operation
    
    // MARK: Add
    
    public func addNode(_ node: Node) {
        assert(!nodes.contains(node))
        nodes.append(node)
        archiveIfNeed()
    }
    
    public func addNodes<S: Sequence>(_ nodes: S) where S.Element == Node {
        self.nodes.append(contentsOf: nodes)
        assert(Set(self.nodes).count == self.nodes.count)
        archiveIfNeed()
    }
    
    public func addEdge(_ edge: Edge) {
        guard edge.to != edge.from else {
            preconditionFailure()
        }
        guard let (inputIndex, outputIndex) = nodeIndexOfEdge(edge) else {
            assertionFailure()
            return
        }
        
        if strict {
            var duplicate = nodes[inputIndex].outputEdge.contains { $0.to == edge.to }
            if directed {
                duplicate = duplicate || nodes[inputIndex].inputEdge.contains { $0.from == edge.from }
            }
            precondition(!duplicate)
        }
        
        nodes[outputIndex].outputEdge.append(OutputEdge(to: edge.to))
        nodes[inputIndex].inputEdge.append(InputEdge(from: edge.from))
           
        archiveIfNeed()
    }
    
    public func addEdges<S: Sequence>(_ edges: S) where S.Element == Edge {
        edges.forEach { addEdge($0) }
    }
    
    // MARK: Read
    
    public func node(id: Node.ID) -> Node? {
        nodes.first { $0.id == id }
    }
    
    // MARK: Remove
    
    public func removeNode(_ node: Node) {
        guard let index = nodes.firstIndex (where: { node == $0 }) else {
            preconditionFailure()
        }
        nodes.remove(at: index)
        archiveIfNeed()
    }
    
    public func removeNodes<S: Sequence>(_ nodes: S) where S.Element == Node {
        nodes.forEach { removeNode($0) }
    }
    
    public func removeEdge(_ edge: Edge) {
        guard let (inputIndex, outputIndex) = nodeIndexOfEdge(edge) else {
            preconditionFailure()
        }
        guard let outputEdgeIndex = nodes[inputIndex].outputEdge.firstIndex(of: OutputEdge(to: edge.to)),
              let inputEdgeIndex = nodes[outputIndex].inputEdge.firstIndex(of: InputEdge(from: edge.from)) else {
                  preconditionFailure()
              }
        nodes[inputIndex].outputEdge.remove(at: outputEdgeIndex)
        nodes[outputIndex].inputEdge.remove(at: inputEdgeIndex)
        
        archiveIfNeed()
    }
    
    public func removeEdges<S: Sequence>(_ edges: S) where S.Element == Edge {
        edges.forEach { removeEdge($0) }
    }
    
    // MARK: - Archive
    
    public func startArchive() {
        isArchiving = true
    }
    
    public func stopArchive() {
        isArchiving = false
    }
    
    public func dropPreviouslyArchive() {
        GraphArchiver.shared.dropAll(id: id)
    }
    
    private func archiveIfNeed() {
        if isArchiving {
            GraphArchiver.shared.addArchive(graph: Graph(deepCopy: self))
        }
    }
    
    // MARK: - Helper
    
    private func nodeIndexOfEdge(_ edge: Edge) -> (input: Int, output: Int)? {
        var input: Int?
        var output: Int?
        for (index, node) in nodes.enumerated() {
            if node.id == edge.from {
                if let input = input {
                    return (input, index)
                } else {
                    output = index
                    continue
                }
            }
            
            if node.id == edge.to {
                if let output = output {
                    return (index, output)
                } else {
                    input = index
                    continue
                }
            }
        }
        return nil
    }
    
}
