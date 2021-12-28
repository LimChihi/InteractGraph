//
//  LayeredGraph.swift
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
   

fileprivate func layout(_ graph: Graph) {
    
    var graph = graph
    removeSelfEdges(&graph)
    acyclic(&graph)
    
}

fileprivate func removeSelfEdges(_ graph: inout Graph) {
    let indices = graph.edges.filter { $0.from == $0.to }.map { $0.id }
    graph.remove(at: indices)
}
    
fileprivate func acyclic(_ graph: inout Graph) {
    
    /// *O(m)* m is the count of edges
    /// - Returns: Edges that need to remove
    func greedy() -> [EdgeIndex] {
        fatalError()
    }
    
    /// *O(n^2)* n is the count of nodes
    /// - Returns: Edges that need to remove
    func dfs() -> [EdgeIndex] {
        
        var result: [EdgeIndex] = []
        var visited: Set<NodeIndex> = []
        
        var stack: [NodeIndex] = []
        
        for currentNode in graph.nodes {
            guard !visited.contains(currentNode.id) else {
                continue
            }
            stack = [currentNode.id]
            while let node = stack.popLast() {
                visited.insert(node)
                for output in graph[node].outputs {
                    if visited.contains(output) {
                        result.append(contentsOf: graph.edgeIndices(from: node, to: output))
                    } else {
                        visited.insert(output)
                        stack.append(output)
                    }
                }
            }
        }
        
        return result
    }
    
    // FIXME: implemented greedy 
//    let edges = graph.storage.edgesCount > graph.storage.nodesCount * graph.storage.nodesCount ? dfs() : greedy()
    let edges = dfs()
    graph.remove(at: edges)
}

#if DEBUG

internal func fileprivate_removeSelfEdges(_ graph: inout Graph) {
    removeSelfEdges(&graph)
}


#endif
