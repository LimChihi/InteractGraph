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
    
    internal typealias Storage = GraphStorage<Node, Edge>
    
    internal let directed: Bool
    
    private var storage: Storage
    
    public init(directed: Bool = true) {
        self.directed = directed
        self.storage = GraphStorage()
    }
    
    public init<SN: Sequence, SE: Sequence>(directed: Bool = true, nodes: SN, edges: SE) where SN.Element == Node, SE.Element == Edge {
        self.directed = directed
        self.storage = GraphStorage()
        
        add(nodes)
        add(edges)
    }
    
    internal var nodes: OptionalElementArray<Storage.Node> {
        storage.nodes
    }
    
    internal var edges: OptionalElementArray<Storage.Edge> {
        storage.edges
    }
    
    internal func map<N, E>(nodeTransform: (Node) throws -> (N), edgeTransform: (Edge) throws -> (E)) rethrows -> GraphStorage<N, E> {
        try storage.map(nodeTransform: nodeTransform, edgeTransform: edgeTransform)
    }
    
    public mutating func add(_ node: Node) {
        makeStorageUniqueIfNotUnique()
        storage.add(node)
    }

    public mutating func add<S: Sequence>(_ nodes: S) where S.Element == Node {
        makeStorageUniqueIfNotUnique()
        storage.add(nodes)
    }
    
    internal subscript(index: NodeIndex) -> Storage.Node {
        storage[index]
    }
    
    internal subscript(node: Storage.Node) -> Node {
        storage[node]
    }
    
    internal func content(of index: NodeIndex) -> Node {
        storage.content(of: index)
    }

    @discardableResult
    internal mutating func remove(at nodeIndex: NodeIndex) -> Node {
        makeStorageUniqueIfNotUnique()
        return storage.remove(at: nodeIndex)
    }

    @discardableResult
    internal mutating func remove<S: Sequence>(at nodeIndices: S) -> ContiguousArray<Node> where S.Element == NodeIndex {
        makeStorageUniqueIfNotUnique()
        return storage.remove(nodesAt: nodeIndices)
    }

    public mutating func add(_ edge: Edge) {
        makeStorageUniqueIfNotUnique()
        storage.add(edge, from: edge.from, to: edge.to)
    }

    public mutating func add<S: Sequence>(_ edges: S) where S.Element == Edge {
        makeStorageUniqueIfNotUnique()
        edges.forEach { add($0) }
    }
    
    internal func edgeIndices(from: NodeIndex, to: NodeIndex) -> ContiguousArray<EdgeIndex> {
        var result = ContiguousArray<EdgeIndex>()
        for edge in edges where edge.from == from && edge.to == to {
            result.append(edge.id)
        }
        return result
    }
    
    internal subscript(index: EdgeIndex) -> Storage.Edge {
        storage[index]
    }
    
    internal subscript(node: Storage.Edge) -> Edge {
        storage[node]
    }
    
    internal func content(of index: EdgeIndex) -> Edge {
        storage.content(of: index)
    }
    
    @discardableResult
    internal mutating func remove(at edgeIndex: EdgeIndex) -> Edge {
        makeStorageUniqueIfNotUnique()
        return storage.remove(at: edgeIndex)
    }

    @discardableResult
    internal mutating func remove<S: Sequence>(at edgeIndices: S) -> ContiguousArray<Edge> where S.Element == EdgeIndex {
        makeStorageUniqueIfNotUnique()
        return storage.remove(edgesAt: edgeIndices)
    }
    
    private mutating func makeStorageUniqueIfNotUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            createdNewStorage()
        }
    }

    private mutating func createdNewStorage() {
        storage = storage.makeCopy()
    }
    
}
