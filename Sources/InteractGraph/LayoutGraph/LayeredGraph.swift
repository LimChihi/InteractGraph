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
   
import Collections

internal struct LayeredGraph {

    internal var graph: Graph
    
    internal var layeredInfos: OptionalElementArray<Info>
    
    internal let root: NodeIndex
    
    internal init(graph: Graph) {
        self.graph = graph
        self.layeredInfos = graph.nodes.map { $0.map { Info(id: $0.id) }}
        self.root = graph.nodes.first { $0.inputs.isEmpty }.map { $0.id } ?? graph.nodes.first!.id
    }
    
    internal func slack(of edge: Graph.Storage.Edge) -> Int? {
        guard let toRank = layeredInfos[edge.to.cast()].rank,
                let fromRank = layeredInfos[edge.from.cast()].rank else {
            return nil
        }
        return toRank - fromRank
    }
    
    struct Info {
        
        let id: NodeIndex
        
        var rank: Int?
        
        var level: Int?
    }
    
}

fileprivate func layout(_ graph: Graph) {
    guard !graph.nodes.isEmpty else {
        return
    }
    var graph = LayeredGraph(graph: graph)
    removeSelfEdges(&graph)
    acyclic(&graph)
    
}

fileprivate func removeSelfEdges(_ layeredGraph: inout LayeredGraph) {
    let indices = layeredGraph.graph.edges.filter { $0.from == $0.to }.map { $0.id }
    layeredGraph.graph.remove(at: indices)
}
    
fileprivate func acyclic(_ layeredGraph: inout LayeredGraph) {
    
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
        
        for currentNode in layeredGraph.graph.nodes {
            guard !visited.contains(currentNode.id) else {
                continue
            }
            stack = [currentNode.id]
            while let node = stack.popLast() {
                visited.insert(node)
                for output in layeredGraph.graph[node].outputs {
                    if visited.contains(output) {
                        result.append(contentsOf: layeredGraph.graph.edgeIndices(from: node, to: output))
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
    layeredGraph.graph.remove(at: edges)
}


fileprivate func longestPath(_ layeredGraph: inout LayeredGraph) {
    
    var visited: Set<NodeIndex> = []
    visited.reserveCapacity(layeredGraph.graph.nodes.count)
    
    func dfs(_ index: NodeIndex) -> Int {
        guard !visited.contains(index) else {
            return layeredGraph.layeredInfos[index.cast()].rank!
        }
        visited.insert(index)
        
        let outputRanks = layeredGraph.graph[index].outputs.map {
            dfs($0) - 1
        }
        let rank = outputRanks.min() ?? 0
        layeredGraph.layeredInfos[index.cast()].rank = rank
        return rank
    }
    
    _ = dfs(layeredGraph.root)
    
}


fileprivate func feasibleTree(_ layeredGraph: inout LayeredGraph) {
    var tightNodes: Set<NodeIndex> = [layeredGraph.root]
    
    func tight() -> Int {
        var queue: [NodeIndex] = [layeredGraph.graph.nodes.first!.id]
        while let node = queue.popLast() {
            guard !tightNodes.contains(node) else {
                continue
            }
            let outputs = layeredGraph.graph[node].outputs
            let nodeRank = layeredGraph.layeredInfos[node.cast()].rank!
            for output in outputs {
                if layeredGraph.layeredInfos[output.cast()].rank! - nodeRank == 1 {
                    tightNodes.insert(output)
                    queue.append(output)
                }
            }
        }
        
        return tightNodes.count
    }
    
    func minSlackEdge() -> Graph.Storage.Edge {
        layeredGraph.graph.edges.minimum { edge -> Int? in
            guard tightNodes.contains(edge.from) != tightNodes.contains(edge.to) else {
                return nil
            }
            return layeredGraph.slack(of: edge)
        }!
    }
    
    while tight() < layeredGraph.graph.nodes.count {
        let edge = minSlackEdge()
        let slack = layeredGraph.slack(of: edge)!
        if tightNodes.contains(edge.from) {
            layeredGraph.layeredInfos[edge.to.cast()].rank! -= slack
        } else {
            layeredGraph.layeredInfos[edge.from.cast()].rank! += slack
        }
    }
    
}


fileprivate func networkSimplex(_ layeredGraph: inout LayeredGraph) {
    longestPath(&layeredGraph)
    fatalError()
}

#if DEBUG

internal func fileprivate_removeSelfEdges(_ graph: inout LayeredGraph) {
    removeSelfEdges(&graph)
}


#endif
