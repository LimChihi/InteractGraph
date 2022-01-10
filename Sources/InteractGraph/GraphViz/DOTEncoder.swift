//
//  DOTEncoder.swift
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


internal struct DOTEncoder {
    
    private let graph: Graph
    
    internal init(_ graph: Graph) {
        self.graph = graph
    }
    
    internal func encode() -> String {
        var lines: [String] = []
        
        do {
            var firstLine: String
            /*
            if graph.strict {
                components.append("strict")
            }
             */
            
            firstLine = graph.directed ? "digraph" : "graph"
            firstLine.append(" {")
            lines.append(firstLine)
        }
        
        /*
        lines.append(contentsOf: encodeSubgraph())
         */
        
        lines.append(contentsOf: encodeNodes())

        
        lines.append("}")
        
        return lines.joined(separator: "\n")
    }
    
    private func encodeSubgraph() -> [String] {
        fatalError()
    }
    
    private func encodeNodes() -> [String] {
        
        var lines: [String] = []
        lines.reserveCapacity(graph.nodes.count)
        
        let edgeString = graph.directed ? "->" : "--"
        for node in graph.nodes {
            let content = node.content
            
            lines.append("\"\(content.id)\"[label=\"\(content.attribute.label)\"]")
            for output in node.outputs {
                let outputID = graph[output].content.id
                // TODO: edge label
                // [label="laalalalalla"]
                lines.append("\"\(content.id)\" \(edgeString) \"\(outputID)\"")
            }
        }
        
        return lines
    }
    
}
