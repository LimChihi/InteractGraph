//
//  Graph.swift
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


internal typealias NodeIndex = GraphStorage<Node, Edge>.NodeIndex

internal typealias EdgeIndex = GraphStorage<Node, Edge>.EdgeIndex

internal typealias InputEdge = NodeIndex

internal typealias OutputEdge = NodeIndex

public struct Graph {
    
    private var storage: GraphStorage<Node, Edge>
    
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
        makeStorageUniqueIfNotUnique()
        storage.add(node: node)
    }

    public mutating func add<S: Sequence>(nodes: S) where S.Element == Node {
        makeStorageUniqueIfNotUnique()
        storage.add(nodes: nodes)
    }
    
    internal func forEach(body: (Node, [InputEdge], [OutputEdge], NodeIndex, inout Bool) -> ()) {
        storage.forEach(body: body)
    }

    internal subscript(nodeIndex: NodeIndex) -> Node {
        storage[nodeIndex]
    }

    @discardableResult
    internal mutating func remove(at nodeIndex: NodeIndex) -> Node {
        makeStorageUniqueIfNotUnique()
        return storage.remove(at: nodeIndex)
    }

    @discardableResult
    internal mutating func remove<S: Sequence>(nodesAt nodeIndices: S) -> ContiguousArray<Node> where S.Element == NodeIndex {
        makeStorageUniqueIfNotUnique()
        return storage.remove(nodesAt: nodeIndices)
    }

    public mutating func add(edge: Edge) {
        makeStorageUniqueIfNotUnique()
        storage.add(edge: edge)
    }

    public mutating func add<S: Sequence>(edges: S) where S.Element == Edge {
        makeStorageUniqueIfNotUnique()
        storage.add(edges: edges)
    }
    
    internal func edgeIndices(from: NodeIndex, to: NodeIndex) -> [EdgeIndex] {
        storage.edgeIndices(from: from, to: to)
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

    @discardableResult
    internal mutating func remove(at edgeIndex: EdgeIndex) -> Edge {
        makeStorageUniqueIfNotUnique()
        return storage.remove(at: edgeIndex)
    }

    @discardableResult
    internal mutating func remove<S: Sequence>(edgesAt edgeIndices: S) -> [Edge] where S.Element == EdgeIndex {
        makeStorageUniqueIfNotUnique()
        return storage.remove(edgesAt: edgeIndices)
    }
    
    private mutating func makeStorageUniqueIfNotUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            createdNewStorage()
        }
    }

    private mutating func createdNewStorage() {
        storage = storage._makeCopy()
    }
    
}
