//
//  Graph.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//

import Foundation

public class Graph {
    
    internal let id: UUID
    
    private let directed: Bool
    
    private let strict: Bool
    
    private var subgraphs: [Subgraph] {
        didSet {
            archiveIfNeed()
        }
    }
    
    private var nodes: [Node] {
        didSet {
            archiveIfNeed()
        }
    }
    
    private var edges: [Edge] {
        didSet {
            archiveIfNeed()
        }
    }
    
    private var isArchiving: Bool
    
    public init(directed: Bool = true, strict: Bool = true) {
        self.id = UUID()
        self.directed = directed
        self.strict = strict
        self.subgraphs = []
        self.nodes = []
        self.edges = []
        self.isArchiving = false
    }
    
    private init(deepCopy instance: Graph) {
        self.id = instance.id
        self.directed = instance.directed
        self.strict = instance.strict
        self.subgraphs = instance.subgraphs
        self.nodes = instance.nodes
        self.edges = instance.edges
        self.isArchiving = instance.isArchiving
    }
    
    // MARK: - Operation
    
    // MARK: Add
    
    public func addNode(_ node: Node) {
        precondition(!nodes.contains(node))
        nodes.append(node)
    }
    
    public func addNodes<S: Sequence>(_ nodes: S) where S.Element == Node {
        self.nodes.append(contentsOf: nodes)
        precondition(Set(self.nodes).count == self.nodes.count)
    }
    
    public func addEdge(_ edge: Edge) {
        precondition(!checkEdgeLegitimacy(edge))
        edges.append(edge)
    }
    
    public func addEdges<S: Sequence>(_ edges: S) where S.Element == Edge {
        precondition(!edges.reduce(true) { partialResult, next in
            partialResult && checkEdgeLegitimacy(next)
        })
        self.edges.append(contentsOf: edges)
    }
    
    // MARK: Remove
    
    public func removeNode(_ node: Node) {
        guard let index = nodes.firstIndex (where: { node == $0 }) else {
            preconditionFailure()
        }
        nodes.remove(at: index)
    }
    
    public func removeNodes<S: Sequence>(_ nodes: S) where S.Element == Node {
        nodes.forEach { removeNode($0) }
    }
    
    public func removeEdge(_ edge: Edge) {
        guard let index = edges.firstIndex (where: { edge == $0 }) else {
            preconditionFailure()
        }
        edges.remove(at: index)
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

    // MARK: Precondition checker
    
    private func checkEdgeLegitimacy(_ edge: Edge) -> Bool {
        guard edge.to != edge.from else {
            return false
        }
        guard strict else {
            return true
        }
        
        var result = edges.contains { edge.from == $0.from && edge.to == $0.to }
        if !directed {
            result = result || edges.contains { edge.from == $0.to && edge.to == $0.from }
        }
        
        return result
    }
    
}
