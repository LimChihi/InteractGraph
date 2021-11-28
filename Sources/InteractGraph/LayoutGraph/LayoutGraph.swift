//
//  LayoutGraph.swift
//  InteractGraph
//
//  Created by lim on 28/11/2021.
//


internal struct LayoutGraph {
    
    internal let storage: AdjacencyListGraph<NodeIndex>
    
    internal let path: [NodeIndex: LayoutGraphIndexPath]
    
    internal let releatedNodes: Set<NodeIndex>?
    
    internal init(_ graph: Graph, focusNode: NodeIndex? = nil) {
        let releatedNodes = focusNode.map {
            filter(graph, focusNodeIndex: $0)
        }
        var (layoutGraph, path) = longestPath(graph, releatedNodes: releatedNodes)
        adjustEdgeWeight(&layoutGraph, path: &path, graph: graph)
        self.storage = layoutGraph
        self.path = path
        self.releatedNodes = releatedNodes
    }

}

fileprivate func longestPath(_ graph: Graph, releatedNodes: Set<NodeIndex>?) -> (layoutGraph: AdjacencyListGraph<NodeIndex>, path: [NodeIndex: LayoutGraphIndexPath]) {
    
    var path: [NodeIndex: LayoutGraphIndexPath] = [:]
    
    var layoutGraph = AdjacencyListGraph<NodeIndex>([[]])
    
    var currentOutputEdge = Set<NodeIndex>()
    
    graph.forEach { node, _, outputEdges, nodeIndex, _ in
        if let releatedNodes = releatedNodes, !releatedNodes.contains(nodeIndex) {
            return
        }
        
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


fileprivate func filter(_ graph: Graph, focusNodeIndex: NodeIndex) -> Set<NodeIndex> {
    
    var releatedNodes: Set<NodeIndex> = []
    
    var stack: [NodeIndex] = [focusNodeIndex]
    
    // inputs
    while let nodeIndex = stack.popLast() {
        releatedNodes.insert(nodeIndex)
        for input in graph.inputEdges(for: nodeIndex) {
            guard !releatedNodes.contains(where: { $0 == input }) &&
                    !stack.contains(where: { $0 == input }) else {
                continue
            }
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
            
            stack.append(output)
        }
    }
    
    return releatedNodes
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
