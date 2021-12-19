//
//  LayoutGraph.swift
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


internal struct LayoutGraph {
    
    internal let storage: AdjacencyListGraph<NodeIndex>
    
    internal let path: [NodeIndex: LayoutGraphIndexPath]
    
    internal let relatedNodes: Set<NodeIndex>?
    
    internal init(_ graph: Graph, focusNode: NodeIndex? = nil) {
        let relatedNodes = focusNode.map {
            filter(graph, focusNodeIndex: $0)
        }
        var (layoutGraph, path) = longestPath(graph, relatedNodes: relatedNodes)
        adjustEdgeWeight(&layoutGraph, path: &path, graph: graph)
        self.storage = layoutGraph
        self.path = path
        self.relatedNodes = relatedNodes
    }

}

fileprivate func longestPath(_ graph: Graph, relatedNodes: Set<NodeIndex>?) -> (layoutGraph: AdjacencyListGraph<NodeIndex>, path: [NodeIndex: LayoutGraphIndexPath]) {
    
    var path: [NodeIndex: LayoutGraphIndexPath] = [:]
    
    var layoutGraph = AdjacencyListGraph<NodeIndex>([[]])
    
    var currentOutputEdge = Set<NodeIndex>()
    
    for node in graph.nodes {
        if let relatedNodes = relatedNodes, !relatedNodes.contains(node.id) {
            continue
        }
        
        let indexPath: AdjacencyListIndexPath
        if currentOutputEdge.contains(where: { node.id == $0 } ) {
            indexPath = layoutGraph.appendElementAtNewRow(node.id)
            currentOutputEdge.removeAll()
        } else {
            indexPath = layoutGraph.appendElementAtLast(node.id)
        }
        
        path[node.id] = LayoutGraphIndexPath(indexPath)
        
        node.outputs.forEach { currentOutputEdge.insert($0) }
    }
    
    return (layoutGraph, path)
}


fileprivate func filter(_ graph: Graph, focusNodeIndex: NodeIndex) -> Set<NodeIndex> {
    
    var relatedNodes: Set<NodeIndex> = []
    
    var stack: [NodeIndex] = [focusNodeIndex]
    
    // inputs
    while let nodeIndex = stack.popLast() {
        relatedNodes.insert(nodeIndex)
        
        for input in graph[nodeIndex].inputs {
            guard !relatedNodes.contains(where: { $0 == input }) &&
                    !stack.contains(where: { $0 == input }) else {
                continue
            }
            stack.append(input)
        }
    }
    
    // outputs
    stack = [focusNodeIndex]
    while let nodeIndex = stack.popLast() {
        relatedNodes.insert(nodeIndex)

        for output in graph[nodeIndex].outputs {
            guard !relatedNodes.contains(where: { $0 == output }) &&
                    !stack.contains(where: { $0 == output }) else {
                continue
            }
            
            stack.append(output)
        }
    }
    
    return relatedNodes
}


fileprivate func adjustEdgeWeight(_ layoutGraph: inout AdjacencyListGraph<NodeIndex>, path: inout [NodeIndex: LayoutGraphIndexPath], graph: Graph) {
    
    for rankIndex in layoutGraph.storage.indices {
        guard rankIndex != 0 else {
            continue
        }
        
        let currentRank: [NodeIndex] = layoutGraph[rankIndex]

        layoutGraph[rankIndex] = currentRank
            .enumerated()
            .map { (levelIndex, nodeIndex) in
                
                let weight = graph[nodeIndex].inputs.reduce(0) { partialResult, input in
                    partialResult + (path[input]?.level ?? 0)
                }
                return (levelIndex, weight)
            }
            .sorted { $0.1 < $1.1 }.enumerated()
            .map { (levelIndex: Int, arg1: (Int, Int)) -> NodeIndex in
                let (i, _) = arg1
                let node = currentRank[i]
                path[node] = LayoutGraphIndexPath(rank: rankIndex, level: levelIndex)
                return node
            }
    }
    
}
