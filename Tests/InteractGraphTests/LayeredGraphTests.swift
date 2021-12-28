//
//  LayeredGraphTests.swift
//  InteractGraph
//
//  Created by limchihi on 12/12/2021.
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
   

import XCTest

@testable
import InteractGraph

final class LayeredGraphTests: XCTestCase {
    
    
    // MARK: removeSelfEdges
    
    func test_removeSelfEdges_withoutSelfEdges() {
        var raw = prepareGraphNode()
        raw.add([
            Edge(from: Node.ID(0x0), to: Node.ID(0x1)),
            Edge(from: Node.ID(0x1), to: Node.ID(0x2)),
            Edge(from: Node.ID(0x3), to: Node.ID(0x4)),
        ])
        var graph = raw
        XCTAssertEqual(raw, graph)
//        fileprivate_removeSelfEdges(&graph)
        XCTAssertEqual(raw, graph)
    }
    
    private func prepareGraphNode() -> Graph {
        var graph = Graph()
        graph.add([
            Node(label: "0x0"),
            Node(label: "0x1"),
            Node(label: "0x2"),
            Node(label: "0x3"),
            Node(label: "0x4"),
        ])
        return graph
    }
    
}
