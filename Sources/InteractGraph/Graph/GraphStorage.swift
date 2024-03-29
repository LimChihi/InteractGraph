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

internal final class GraphStorage<NodeContent: Identifiable, EdgeContent> {

    internal typealias NodeIndex = TypeIndex<NodeContent>
    
    internal typealias EdgeIndex = TypeIndex<EdgeContent>
    
    internal typealias InputEdge = NodeIndex
    
    internal typealias OutputEdge = NodeIndex
    
    internal private(set) var nodeContents: OptionalElementArray<NodeContent>
    
    internal private(set) var edgeContents: OptionalElementArray<EdgeContent>
    
    internal private(set) var nodes: OptionalElementArray<Node>
    
    internal private(set) var edges: OptionalElementArray<Edge>
    
    @inline(__always)
    internal init() {
        self.nodeContents = []
        self.edgeContents = []
        self.nodes = []
        self.edges = []
    }
    
    @inline(__always)
    private init(nodeContents: OptionalElementArray<NodeContent>, edgeContents: OptionalElementArray<EdgeContent>, nodes: OptionalElementArray<GraphStorage<NodeContent, EdgeContent>.Node>, edges: OptionalElementArray<GraphStorage<NodeContent, EdgeContent>.Edge>) {
        self.nodeContents = nodeContents
        self.edgeContents = edgeContents
        self.nodes = nodes
        self.edges = edges
    }
    
    @inlinable
    internal func makeCopy() -> GraphStorage {
        GraphStorage(nodeContents: nodeContents, edgeContents: edgeContents, nodes: nodes, edges: edges)
    }
    
    internal func map<N, E>(nodeTransform: (NodeContent) throws -> (N), edgeTransform: (EdgeContent) throws -> (E)) rethrows -> GraphStorage<N, E> {
        typealias Storage = GraphStorage<N, E>
        
        let storage = Storage(
            nodeContents: try nodeContents.map { try $0.map { try nodeTransform($0) } },
            edgeContents: try edgeContents.map { try $0.map { try edgeTransform($0) } },
            nodes: [],
            edges: []
        )
        
        storage.nodes = nodes.map { (e: Node?) -> Storage.Node? in
            guard let e = e else {
                return nil
            }
            return Storage.Node(
                graph: storage,
                id: e.id.cast(),
                inputs: unsafeBitCast(e.inputs, to: ContiguousArray<Storage.InputEdge>.self),
                outputs: unsafeBitCast(e.outputs, to: ContiguousArray<Storage.OutputEdge>.self)
            )
        }
        
        storage.edges = edges.map { (e: Edge?) -> Storage.Edge? in
            guard let e = e else {
                return nil
            }
            return Storage.Edge(graph: storage, id: e.id.cast(), from: e.from.cast(), to: e.to.cast())
        }
        
        return storage
    }
    
    // MARK: - Node
    
    // MARK: created
    
    @inlinable
    @discardableResult
    internal func add(_ content: NodeContent) -> NodeIndex {
        let index = nodeContents.append(content)
        nodes.append(Node(graph: self, id: index))
        return index
    }
    
    @inlinable
    @discardableResult
    internal func add<S: Sequence>(_ contents: S) -> ContiguousArray<NodeIndex> where S.Element == NodeContent {
        ContiguousArray(contents.map { add($0) })
    }
    
    // MARK: retrieved
    
    @inlinable
    internal subscript(nodeIndex: NodeIndex) -> Node {
        nodes[nodeIndex.cast()]
    }
    
    @inlinable
    internal subscript(node: Node) -> NodeContent {
        content(of: node.id)
    }
    
    @inlinable
    internal func content(of index: NodeIndex) -> NodeContent {
        nodeContents[index]
    }
    
    // MARK: deleted
    
    @inlinable
    @discardableResult
    internal func remove(at nodeIndex: NodeIndex) -> NodeContent {
        let node = nodes[nodeIndex.cast()]
        
        node.inputs.forEach {
            removeNodeEdge(from: nodeIndex, to: $0)
        }
        
        node.outputs.forEach {
            removeNodeEdge(from: $0, to: nodeIndex)
        }
        
        for edge in edges {
            guard edge.from == nodeIndex || edge.to == nodeIndex else {
                continue
            }
            edges.remove(at: edge.id.cast())
            edgeContents.remove(at: edge.id)
        }
        
        nodes.remove(at: nodeIndex.cast())
        let content = nodeContents.remove(at: nodeIndex)
        return content
    }
    
    @inlinable
    @discardableResult
    internal func remove<S: Sequence>(nodesAt nodeIndices: S) -> ContiguousArray<NodeContent> where S.Element == NodeIndex {
        ContiguousArray(nodeIndices.map { remove(at: $0) })
    }
    
    // MARK: - Edge
    // MARK: created
    
    @inlinable
    @discardableResult
    internal func add(_ content: EdgeContent, from: NodeContent.ID, to: NodeContent.ID) -> EdgeIndex {
        guard let (fromIndex, toIndex) = nodeIndices(id0: from, id1: to) else {
            preconditionFailure("Nodes not found")
        }
        return add(content, from: fromIndex, to: toIndex)
    }
    
    @inlinable
    @discardableResult
    internal func add(_ content: EdgeContent, from: NodeIndex, to: NodeIndex) -> EdgeIndex {
        nodes[from.cast()].outputs.append(to)
        nodes[to.cast()].inputs.append(from)
        
        let index = edgeContents.append(content)
        edges.append(Edge(graph: self, id: index, from: from, to: to))
        return index
    }
    
    // MARK: read
    
    @inlinable
    internal subscript(edgeIndex: EdgeIndex) -> Edge {
        edges[edgeIndex.cast()]
    }
    
    @inlinable
    internal subscript(edge: Edge) -> EdgeContent {
        edgeContents[edge.id]
    }
    
    @inlinable
    internal func content(of index: EdgeIndex) -> EdgeContent {
        edgeContents[index]
    }
    
    // MARK: deleted
    
    @inlinable
    @discardableResult
    internal func remove(at index: EdgeIndex) -> EdgeContent {
        let edge = edges[index.cast()]
        removeNodeEdge(from: edge.from, to: edge.to)
        edges.remove(at: index.cast())
        let content = edgeContents.remove(at: index)
        return content
    }
    
    @inlinable
    @discardableResult
    internal func remove<S: Sequence>(edgesAt edgeIndices: S) -> ContiguousArray<EdgeContent> where S.Element == EdgeIndex {
        ContiguousArray(edgeIndices.map { remove(at: $0) })
    }
    
    // MARK: - helper
    
    private func removeNodeEdge(from: NodeIndex, to: NodeIndex) {
        nodes[from.cast()].outputs.removeAll {
            $0 == to
        }
        
        nodes[to.cast()].inputs.removeAll {
            $0 == from
        }
    }
    
    private func nodeIndices(id0: NodeContent.ID, id1: NodeContent.ID) -> (NodeIndex, NodeIndex)? {
        var index0: NodeIndex?
        var index1: NodeIndex?
        
        for index in nodeContents.indices {
            let node = nodeContents[index]
            if node.id == id0 {
                if let index1 = index1 {
                    return (index.cast(), index1)
                } else {
                    index0 = index.cast()
                    continue
                }
            }
            
            if node.id == id1 {
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
    
    internal struct Node {
        
        fileprivate unowned let graph: GraphStorage
        
        internal let id: NodeIndex
        
        @nonobjc
        internal fileprivate(set) var inputs: ContiguousArray<InputEdge>
        
        @nonobjc
        internal fileprivate(set) var outputs: ContiguousArray<OutputEdge>
        
        @inlinable
        internal init(graph: GraphStorage, id: NodeIndex, inputs: ContiguousArray<InputEdge> = [], outputs: ContiguousArray<OutputEdge> = []) {
            self.graph = graph
            self.id = id
            self.inputs = inputs
            self.outputs = outputs
        }
        
        @inlinable
        internal var content: NodeContent {
            graph.content(of: id)
        }
        
    }
    
    internal struct Edge: Identifiable {
        
        fileprivate unowned let graph: GraphStorage
        
        internal let id: EdgeIndex
        
        internal let from: NodeIndex
        
        internal let to: NodeIndex
        
        @inlinable
        internal var content: EdgeContent {
            graph.content(of: id)
        }
    }
    
}


extension GraphStorage: Codable where NodeContent: Codable, EdgeContent: Codable {
    
    private struct CodableNode: Codable {
        
        internal let inputs: ContiguousArray<InputEdge>
        
        internal let outputs: ContiguousArray<OutputEdge>
        
        @inlinable
        internal init(_ node: Node) {
            self.inputs = node.inputs
            self.outputs = node.outputs
        }
        
    }
    
    private struct CodableEdge: Codable {
        
        internal let from: NodeIndex
        
        internal let to: NodeIndex
        
        @inlinable
        internal init(_ edge: Edge) {
            self.from = edge.from
            self.to = edge.to
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case nodes
        
        case nodeContents
        
        case edges
        
        case edgeContents
        
    }
    
    internal convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(
            nodeContents: try container.decode(for: .nodeContents),
            edgeContents: try container.decode(for: .edgeContents),
            nodes: [],
            edges: []
        )
        
        let codableNodes = try container.decode(
            OptionalElementArray<CodableNode>.self,
            forKey: .nodes
        )
        let codableEdges = try container.decode(
            OptionalElementArray<CodableEdge>.self,
            forKey: .edges
        )
        
        self.nodes = codableNodes.map { element, index in
            element.map {
                Node(graph: self, id: NodeIndex(index.rawValue), inputs: $0.inputs, outputs: $0.outputs)
            }
        }
        
        self.edges = codableEdges.map { element, index in
            element.map {
                Edge(graph: self, id: EdgeIndex(index.rawValue), from: $0.from, to: $0.to)
            }
        }
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodeContents, forKey: .nodeContents)
        try container.encode(edgeContents, forKey: .edgeContents)
        try container.encode(nodes.map { CodableNode($0) }, forKey: .nodes)
        try container.encode(edges.map { CodableEdge($0) }, forKey: .edges)
    }
}

extension KeyedDecodingContainer {
    
    @inlinable
    internal func decode<T>(for key: KeyedDecodingContainer<K>.Key) throws -> T where T : Decodable {
        try decode(T.self, forKey: key)
    }

}
