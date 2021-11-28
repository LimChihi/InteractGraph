//
//  LayoutGraph.swift
//  InteractGraph
//
//  Created by lim on 28/11/2021.
//


internal struct LayoutGraph {
    
    internal let storage: AdjacencyListGraph<NodeIndex> 
    
    internal let path: [NodeIndex: LayoutGraphIndexPath]
    
    internal init(_ graph: Graph, focusNode: NodeIndex? = nil) {
        var graph = graph
        if let focusNode = focusNode {
            graph = filter(graph, focusNodeIndex: focusNode)
        }
        var (layoutGraph, path) = longestPath(graph)
        adjustEdgeWeight(&layoutGraph, path: &path, graph: graph)
        self.storage = layoutGraph
        self.path = path
    }

}

fileprivate func longestPath(_ graph: Graph) -> (layoutGraph: AdjacencyListGraph<NodeIndex>, path: [NodeIndex: LayoutGraphIndexPath]) {
    
    var path: [NodeIndex: LayoutGraphIndexPath] = [:]
    
    var layoutGraph = AdjacencyListGraph<NodeIndex>([[]])
    
    var currentOutputEdge = Set<NodeIndex>()
    
    graph.forEach { node, _, outputEdges, nodeIndex, _ in
        let indexPath: AdjacencyListIndexPath
        if currentOutputEdge.contains(where: { nodeIndex == $0 } ) {
            indexPath = layoutGraph.appendElementAtNewRow(nodeIndex)
            currentOutputEdge.removeAll()
        } else {
            indexPath = layoutGraph.appendElementAtLast(nodeIndex)
        }
        
        
        path[nodeIndex] = LayoutGraphIndexPath(indexPath)
        
        outputEdges.forEach { currentOutputEdge.insert($0) }
    }
    
    return (layoutGraph, path)
}


fileprivate func filter(_ graph: Graph, focusNodeIndex: NodeIndex) -> Graph {
    
    
    var releatedNodes: Set<NodeIndex> = []
    var releatedEdges: Set<EdgeIndex> = []
    
    var stack: [NodeIndex] = [focusNodeIndex]
    
    // inputs
    while let nodeIndex = stack.popLast() {
        releatedNodes.insert(nodeIndex)
        for input in graph.inputEdges(for: nodeIndex) {
            guard !releatedNodes.contains(where: { $0 == input }) &&
                    !stack.contains(where: { $0 == input }) else {
                continue
            }
            releatedEdges.insert(graph.edgeIndex(from: input, to: nodeIndex)!)
            stack.append(input)
        }
    }
    
    // outputs
    stack = [focusNodeIndex]
    while let nodeIndex = stack.popLast() {
        releatedNodes.insert(nodeIndex)

        for output in graph.outputEdges(for: nodeIndex) {
            guard !releatedNodes.contains(where: { $0 == output }) &&
                    !stack.contains(where: { $0 == output }) else {
                continue
            }
            
            releatedEdges.insert(graph.edgeIndex(from: output, to: nodeIndex)!)
            stack.append(output)
        }
    }
    
    var newNodes: [Node] = []
    newNodes.reserveCapacity(releatedNodes.count)
    graph.forEach { node, _, _, nodeIndex, _ in
        if releatedNodes.contains(nodeIndex) {
            newNodes.append(node)
        }
    }
    
    var newEdges: [Edge] = []
    newEdges.reserveCapacity(releatedEdges.count)
    graph.forEach { edge, edgeIndex, _ in
        if releatedEdges.contains(edgeIndex) {
            newEdges.append(edge)
        }
    }
    
    return Graph(nodes: newNodes, edges: newEdges)
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
                
                let weight = graph.inputEdges(for: nodeIndex).reduce(0) { partialResult, input in
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
