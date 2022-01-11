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
    
    internal static func encode(_ viewGraph: ViewGraph.Storage, directed: Bool) -> String {
        var lines: [String] = []
        
        do {
//            var firstLine: String
            /*
            if graph.strict {
                firstLine.append("strict")
            }
             */
            
            let firstLine = directed ? "digraph {" : "graph {"
            lines.append(firstLine)
        }
        
        /*
        lines.append(contentsOf: encodeSubgraph())
         */
        
        lines.append(contentsOf: encodeNodes(viewGraph, directed: directed))
        
        lines.append("}")
        
        return lines.joined(separator: "\n")
    }
    
    private func encodeSubgraph() -> [String] {
        fatalError()
    }
    
    private static func encodeNodes(_ viewGraph: ViewGraph.Storage, directed: Bool) -> [String] {
        
        var lines: [String] = []
        lines.reserveCapacity(viewGraph.nodes.count + viewGraph.edges.count)
        
        let edgeString = directed ? "->" : "--"
        for node in viewGraph.nodes {
            let content = node.content
            
            lines.append("\"\(content.id)\"[label=\"\(content.attribute.label)\"]")
            for output in node.outputs {
                let outputID = viewGraph[output].content.id
                // TODO: edge label
                // [label="laalalalalla"]
                lines.append("\"\(content.id)\" \(edgeString) \"\(outputID)\"")
            }
        }
        
        return lines
    }
    
}
