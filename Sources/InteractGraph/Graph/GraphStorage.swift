//
//  GraphStorage.swift
//  InteractGraph
//
//  Created by limchihi on 28/11/2021.
//
//  Copyright (c) 2021 Lin Zhiyi <limchihi@foxmail.com>
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

import Collections

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
    
    private var nodes: OptionalElementArray<Node<NodeContent>>
    
    private var edges: OptionalElementArray<Edge<EdgeContent>>
    
    internal init(directed: Bool) {
        self.directed = directed
        self.nodes = []
        self.edges = []
    }
    
    private init(directed: Bool, nodes: OptionalElementArray<Node<NodeContent>>, edges: OptionalElementArray<Edge<EdgeContent>>) {
        self.directed = directed
        self.nodes = nodes
        self.edges = edges
    }

    internal func _makeCopy() -> GraphStorage {
        GraphStorage(directed: directed, nodes: nodes, edges: edges)
    }
    
//    internal var allEdges: [EdgeIndex] { }
    
    internal var allEdges: [(index: EdgeIndex, from: NodeIndex, to: NodeIndex)] {
        var result: [(index: EdgeIndex, from: NodeIndex, to: NodeIndex)] = []
        result.reserveCapacity(edges.count)
        for index in edges.indices {
            let edge = edges[index]
            result.append((index.cast(), edge.fromNodeIndex, edge.toNodeIndex))
        }
        return result
    }
    
    // MARK: - Node
    
    @discardableResult
    internal func add(node: NodeContent) -> NodeIndex {
        nodes.append(Node(node)).cast()
    }
    
    @discardableResult
    internal func add<S: Sequence>(nodes newNodes: S) -> ContiguousArray<NodeIndex> where S.Element == NodeContent {
        var nodesIterator = newNodes.makeIterator()
        var current = nodesIterator.next()
        var indices: ContiguousArray<NodeIndex> = []
        indices.reserveCapacity(nodes.underestimatedCount)
        
        while let node = current {
            indices.append(nodes.append(Node(node)).cast())
            current = nodesIterator.next()
        }
        
        return indices
    }
    
    internal subscript(nodeIndex: NodeIndex) -> NodeContent {
        nodes[nodeIndex.cast()].content
    }
    
    internal func forEach(body: (NodeContent, [InputEdge], [OutputEdge], NodeIndex, inout Bool) -> ()) {
        var stop = false
        
        for index in nodes.indices {
            let node = nodes[index]
            body(node.content, node.inputs, node.outputs, index.cast(), &stop)
            if stop {
                return
            }
        }
    }
    
    @discardableResult
    internal func remove(at nodeIndex: NodeIndex) -> NodeContent {
        let node = nodes[nodeIndex.cast()]
        
        node.inputs.forEach {
            removeNodeEdge(from: nodeIndex, to: $0)
        }
        
        node.outputs.forEach {
            removeNodeEdge(from: $0, to: nodeIndex)
        }
        
        for index in edges.indices {
            let edge = edges[index]
            guard edge.fromNodeIndex == nodeIndex || edge.toNodeIndex == nodeIndex else {
                continue
            }
            edges.remove(at: index)
        }
        
        nodes.remove(at: nodeIndex.cast())
        return node.content
    }
    
    @discardableResult
    internal func remove<S: Sequence>(nodesAt nodeIndices: S) -> ContiguousArray<NodeContent> where S.Element == NodeIndex {
        let deletedNodes = nodeIndices.map { remove(at: $0) }
        return ContiguousArray(deletedNodes)
    }
    
    // MARK: - Edge
    
    @discardableResult
    internal func add(edge: EdgeContent) -> EdgeIndex {
        let edge = prepareGraphEdge(for: edge)
        return edges.append(edge).cast()
    }
    
    @discardableResult
    internal func add<S: Sequence>(edges newEdges: S) -> ContiguousArray<EdgeIndex> where S.Element == EdgeContent {
        var edgesIterator = newEdges.makeIterator()
        var current = edgesIterator.next()
        var indices: ContiguousArray<EdgeIndex> = []
        indices.reserveCapacity(newEdges.underestimatedCount)
        
        while let edge = current {
            indices.append(edges.append(prepareGraphEdge(for: edge)).cast())
            current = edgesIterator.next()
        }
        
        return indices
    }
    
    internal func edgeIndices(from: NodeIndex, to: NodeIndex) -> [EdgeIndex] {
        var result: [EdgeIndex] = []
        for index in edges.indices {
            let edge = edges[index]
            guard edge.fromNodeIndex == from && edge.toNodeIndex == to else {
                continue
            }
            
            result.append(index.cast())
        }
        
        return result
    }
    
    internal subscript(edgeIndex: EdgeIndex) -> EdgeContent {
        edges[edgeIndex.cast()].content
    }
    
    internal func forEach(body: (EdgeContent, EdgeIndex, inout Bool) -> ()) {
        var stop = false
        for index in edges.indices {
            let edge = edges[index]
            body(edge.content, index.cast(), &stop)
            if stop {
                return
            }
        }
    }
    
    internal func inputEdges(for nodeIndex: NodeIndex) -> [InputEdge] {
        nodes[nodeIndex.cast()].inputs
    }
    
    internal func outputEdges(for nodeIndex: NodeIndex) -> [OutputEdge] {
        nodes[nodeIndex.cast()].outputs
    }
    
    @discardableResult
    internal func remove(at edgeIndex: EdgeIndex) -> EdgeContent {
        let edge = edges[edgeIndex.cast()]
        removeNodeEdge(from: edge.fromNodeIndex, to: edge.toNodeIndex)
        edges.remove(at: edgeIndex.cast())
        
        return edge.content
    }
    
    @discardableResult
    internal func remove<S: Sequence>(edgesAt edgeIndices: S) -> [EdgeContent] where S.Element == EdgeIndex {
        edgeIndices.map { remove(at: $0) }
    }
    
    // MARK: - Connected Graph
    
    internal func getConnectedSubgraphs() -> ContiguousArray<SubgraphStorage> {
        var result = ContiguousArray<SubgraphStorage>()
        var passByNode = Set<NodeIndex>()
        
        for index in nodes.indices {

            guard !passByNode.contains(index.cast()) else {
                continue
            }
            
            let subgraph = SubgraphStorage(graph: self)
            var queue: Deque<NodeIndex> = [index.cast()]
            while let first = queue.popFirst() {
                guard !passByNode.contains(index.cast()) else {
                    continue
                }
                let node = nodes[first.cast()]
                
                queue.append(contentsOf: node.outputs.filter({ !passByNode.contains($0) }))
                queue.append(contentsOf: node.inputs.filter({ !passByNode.contains($0) }))
                passByNode.insert(index.cast())
                subgraph.nodeIndices.append(index.cast())
            }
            
            result.append(subgraph)
            if passByNode.count == nodes.count {
                break
            }
        }
        return result
    }
    
    // MARK: - helper
    
    private func removeNodeEdge(from: NodeIndex, to: NodeIndex) {
        if let outputIndex = nodes[from.cast()].outputs.firstIndex(where: { $0 == to }) {
            nodes[from.cast()].outputs.remove(at: outputIndex)
        }
        
        if let inputIndex = nodes[to.cast()].inputs.firstIndex(where: { $0 == from }) {
            nodes[to.cast()].inputs.remove(at: inputIndex)
        }
    }
    
    private func nodeIndices(id0: NodeContent.ID, id1: NodeContent.ID) -> (NodeIndex, NodeIndex)? {
        var index0: NodeIndex?
        var index1: NodeIndex?
        
        for index in nodes.indices {
            let node = nodes[index]
            if node.content.id == id0 {
                if let index1 = index1 {
                    return (index.cast(), index1)
                } else {
                    index0 = index.cast()
                    continue
                }
            }
            
            if node.content.id == id1 {
                if let index0 = index0 {
                    return (index0, index.cast())
                } else {
                    index1 = index.cast()
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
        
        nodes[fromNodeIndex.cast()].outputs.append(toNodeIndex)
        nodes[toNodeIndex.cast()].inputs.append(fromNodeIndex)
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
