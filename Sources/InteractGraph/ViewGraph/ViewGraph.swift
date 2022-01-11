//
//  ViewGraph.swift
//  InteractGraph
//
//  Created by limchihi on 9/1/2022.
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

import Foundation
   
internal struct ViewGraph {
    
    internal typealias Storage = GraphStorage<ViewNode, ViewEdge>
    
    internal var directed: Bool
    
    private var storage: GraphStorage<ViewNode, ViewEdge>

    internal init(graph: Graph) async throws {
        self.directed = graph.directed
        self.storage = try await render(graph)
    }
    
    // MARK: retrieved
    
    internal var nodes: OptionalElementArray<ViewNode> {
        storage.nodeContents
    }
    
    internal var edges: OptionalElementArray<ViewEdge> {
        storage.edgeContents
    }
    
    // MARK: updated
    
    internal mutating func update(_ graph: Graph) async throws {
        self.directed = graph.directed
        self.storage = try await render(graph)
    }
    
    // MARK: deleted
    
}

fileprivate func render(_ graph: Graph, focusNode: NodeIndex? = nil) async throws -> ViewGraph.Storage {
    let storage = graph.map(nodeTransform: { node in
        ViewNode(id: node.id, attribute: node.attribute, frame: .null)
    }, edgeTransform: { edge in
        ViewEdge(from: edge.from, to: edge.to, attribute: edge.attribute, controlPoints: [])
    })
    return try await render(storage, directed: graph.directed, focusNode: focusNode)
}


fileprivate func render(_ viewGraph: ViewGraph.Storage, directed: Bool, focusNode: NodeIndex? = nil) async throws -> ViewGraph.Storage {
    
    let dot = DOTEncoder.encode(viewGraph, directed: directed)
    
    let layoutJson = try await render(dot: dot)
    
//    DOTDecoder.decode(layoutJson)
    
    return GraphStorage()
}
