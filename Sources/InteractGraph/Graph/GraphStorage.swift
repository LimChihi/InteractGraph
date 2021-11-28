//
//  GraphStorage.swift
//  InteractGraph
//
//  Created by lim on 28/11/2021.
//

import Foundation

internal protocol GraphStorageEdge {
    
    associatedtype NodeID: Equatable
    
    var from: NodeID { get }
    
    var to: NodeID { get }
    
}


internal protocol GraphStorageNode {
    
    associatedtype ID: Equatable
    
    var id: ID { get }
    
}


internal final class GraphStorage<NodeContent: GraphStorageNode, EdgeContent: GraphStorageEdge> where NodeContent.ID == EdgeContent.NodeID {
    
    internal typealias NodeIndex = TypeIndex<NodeContent>
    
    internal typealias EdgeIndex = TypeIndex<EdgeContent>
    
    internal let directed: Bool
    
    private var nodes: [Node<NodeContent>?]
    
    private var edges: [Edge<EdgeContent>?]
    
    internal init(directed: Bool) {
        self.directed = directed
        self.nodes = []
        self.edges = []
    }
    
    internal var allEdges: [(index: EdgeIndex, from: NodeIndex, to: NodeIndex)] {
        var result: [(index: EdgeIndex, from: NodeIndex, to: NodeIndex)] = []
        result.reserveCapacity(edges.count)
        for index in edges.indices {
            guard let edge = edges[index] else {
                continue
            }
            result.append((EdgeIndex(index), edge.fromNodeIndex, edge.toNodeIndex))
        }
        return result
    }
    
    // MARK: - Node
    
    @discardableResult
    internal func add(node: NodeContent) -> NodeIndex {
        let index = nodes.firstIndex(where: { $0 == nil })
        
        let newNode = Node(node)
        if let index = index {
            nodes[index] = newNode
            return NodeIndex(index)
        } else {
            let index = nodes.endIndex
            nodes.append(newNode)
            return NodeIndex(index)
        }
    }
    
    @discardableResult
    internal func add<S: Sequence>(nodes: S) -> [NodeIndex] where S.Element == NodeContent {
        
        var nodesIterator = nodes.makeIterator()
        var current = nodesIterator.next()
        var indices: [NodeIndex] = []
        indices.reserveCapacity(nodes.underestimatedCount)
        
        for index in self.nodes.indices {
            guard let node = current else {
                break
            }
            guard self.nodes[index] == nil else {
                continue
            }
            self.nodes[index] = Node(node)
            indices.append(NodeIndex(index))
            current = nodesIterator.next()
        }
        
        while let node = current {
            let index = self.nodes.endIndex
            self.nodes.append(Node(node))
            indices.append(NodeIndex(index))
            current = nodesIterator.next()
        }
        
        return indices
    }
    
    internal subscript(nodeIndex: NodeIndex) -> NodeContent {
        nodes[nodeIndex]!.content
    }
    
    internal func forEach(body: (NodeContent, [InputEdge], [OutputEdge], NodeIndex, inout Bool) -> ()) {
        var stop = false
        for index in nodes.indices {
            guard let node = nodes[index] else {
                continue
            }
            body(node.content, node.inputs, node.outputs, NodeIndex(index), &stop)
            if stop {
                return
            }
        }
    }
    
    @discardableResult
    internal func remove(at nodeIndex: NodeIndex) -> NodeContent {
        let node = nodes[nodeIndex]!
        
        node.inputs.forEach {
            removeNodeEdge(from: nodeIndex, to: $0)
        }
        
        node.outputs.forEach {
            removeNodeEdge(from: $0, to: nodeIndex)
        }
        
        for index in edges.indices {
            guard let edge = edges[index] else {
                continue
            }
            guard edge.fromNodeIndex == nodeIndex || edge.toNodeIndex == nodeIndex else {
                continue
            }
            edges[index] = nil
        }
        
        nodes[nodeIndex] = nil
        return node.content
    }
    
    @discardableResult
    internal func remove<S: Sequence>(nodesAt nodeIndices: S) -> [NodeContent] where S.Element == NodeIndex {
        nodeIndices.map { remove(at: $0) }
    }
    
    // MARK: - Edge
    
    @discardableResult
    internal func add(edge: EdgeContent) -> EdgeIndex {
        let edge = prepareGraphEdge(for: edge)
        
        let index = edges.firstIndex(where: { $0 == nil })
        if let index = index {
            edges[index] = edge
            return EdgeIndex(index)
        } else {
            let index = edges.endIndex
            edges.append(edge)
            return EdgeIndex(index)
        }
    }
    
    @discardableResult
    internal func add<S: Sequence>(edges: S) -> [EdgeIndex] where S.Element == EdgeContent {
        var edgesIterator = edges.makeIterator()
        var current = edgesIterator.next()
        var indices: [EdgeIndex] = []
        indices.reserveCapacity(edges.underestimatedCount)
        
        for index in self.edges.indices {
            guard let edge = current else {
                break
            }
            guard self.edges[index] == nil else {
                continue
            }
            self.edges[index] = prepareGraphEdge(for: edge)
            indices.append(EdgeIndex(index))
            current = edgesIterator.next()
        }

        while let edge = current {
            let index = self.edges.endIndex
            self.edges.append(prepareGraphEdge(for: edge))
            indices.append(EdgeIndex(index))
            current = edgesIterator.next()
        }
        
        return indices
    }
    
    internal func edgeIndex(from: NodeIndex, to: NodeIndex) -> EdgeIndex? {
        for index in edges.indices {
            guard let edge = edges[index] else {
                continue
            }
            guard edge.fromNodeIndex == from && edge.toNodeIndex == to else {
                continue
            }
            
            return EdgeIndex(index)
        }
        return nil
    }
    
    internal subscript(edgeIndex: EdgeIndex) -> EdgeContent {
        edges[edgeIndex]!.content
    }
    
    internal func forEach(body: (EdgeContent, EdgeIndex, inout Bool) -> ()) {
        var stop = false
        for index in edges.indices {
            guard let edge = edges[index] else {
                continue
            }
            body(edge.content, EdgeIndex(index), &stop)
            if stop {
                return
            }
        }
    }
    
    internal func inputEdges(for nodeIndex: NodeIndex) -> [InputEdge] {
        nodes[nodeIndex]!.inputs
    }
    
    internal func outputEdges(for nodeIndex: NodeIndex) -> [OutputEdge] {
        nodes[nodeIndex]!.outputs
    }
    
    @discardableResult
    internal func remove(at edgeIndex: EdgeIndex) -> EdgeContent {
        let edge = edges[edgeIndex]!
        removeNodeEdge(from: edge.fromNodeIndex, to: edge.toNodeIndex)
        edges[edgeIndex] = nil
        
        return edge.content
    }
    
    @discardableResult
    internal func remove<S: Sequence>(edgesAt edgeIndices: S) -> [EdgeContent] where S.Element == EdgeIndex {
        edgeIndices.map { remove(at: $0) }
    }
    
    // MARK: - helper
    
    private func removeNodeEdge(from: NodeIndex, to: NodeIndex) {
        if let outputIndex = nodes[from]?.outputs.firstIndex(where: { $0 == to }) {
            nodes[from]?.outputs.remove(at: outputIndex)
        }
        
        if let inputIndex = nodes[to]?.inputs.firstIndex(where: { $0 == from }) {
            nodes[to]?.inputs.remove(at: inputIndex)
        }
    }
    
    private func nodeIndices(id0: NodeContent.ID, id1: NodeContent.ID) -> (NodeIndex, NodeIndex)? {
        var index0: NodeIndex?
        var index1: NodeIndex?
        
        for (index, node) in nodes.enumerated() {
            if node?.content.id == id0 {
                if let index1 = index1 {
                    return (NodeIndex(index), index1)
                } else {
                    index0 = NodeIndex(index)
                    continue
                }
            }
            
            if node?.content.id == id1 {
                if let index0 = index0 {
                    return (index0, NodeIndex(index))
                } else {
                    index1 = NodeIndex(index)
                    continue
                }
            }
        }
        
        return nil
    }
    
    private func prepareGraphEdge(for edge: EdgeContent) -> Edge<EdgeContent> {
        assert(edge.from != edge.to)
        guard let (fromNodeIndex, toNodeIndex) = nodeIndices(id0: edge.from, id1: edge.to) else {
            preconditionFailure("Nodes Not Found")
        }
        
        nodes[fromNodeIndex]?.outputs.append(toNodeIndex)
        nodes[toNodeIndex]?.inputs.append(fromNodeIndex)
        return Edge(fromNodeIndex: fromNodeIndex, toNodeIndex: toNodeIndex, content: edge)
    }
    
}


extension GraphStorage {
    
    internal typealias InputEdge = NodeIndex
    
    internal typealias OutputEdge = NodeIndex
    
    private struct Node<Content> {
        
        internal var inputs: [InputEdge]
        
        internal var outputs: [OutputEdge]
        
        internal let content: Content
        
        internal init(_ content: Content) {
            self.inputs = []
            self.outputs = []
            self.content = content
        }
        
    }
    
    private struct Edge<Content> {
        
        internal let fromNodeIndex: NodeIndex
        
        internal let toNodeIndex: NodeIndex
        
        internal let content: Content
        
    }
    
}
