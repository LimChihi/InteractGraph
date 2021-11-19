//
//  LayoutGraph.swift
//  
//
//  Created by lim on 19/11/2021.
//


internal struct LayoutGraph {
    
    internal typealias Rank = [Level]
    
    internal typealias Level = Node
    
    internal let ranks: [Rank]
    
    internal let path: [Level.ID: Path]
    
    internal init(_ graph: Graph) {
        var (layoutGraph, path) = longestPath(graph)
        adjustEdgeWeight(&layoutGraph, path: &path)
        self.ranks = layoutGraph
        self.path = path
    }
    
    
    internal struct Path {
        
        internal var rank: Int
        
        internal var level: Int
        
    }
    
}


fileprivate func longestPath(_ graph: Graph) -> (layoutGraph: [LayoutGraph.Rank], path: [Node.ID: LayoutGraph.Path]) {
    
    var positions: [Node.ID: LayoutGraph.Path] = [:]
    
    var layoutGraph: [LayoutGraph.Rank] = [[]]
    
    var currentOutputEdge = Set<OutputEdge>()
    
    for node in graph.nodes {
        if currentOutputEdge.contains(where: { node.id == $0.to } ) {
            layoutGraph.append([node])
            currentOutputEdge.removeAll()
        } else {
            layoutGraph[layoutGraph.endIndex - 1].append(node)
        }
        positions[node.id] = LayoutGraph.Path(rank: layoutGraph.endIndex - 1, level: layoutGraph[layoutGraph.endIndex - 1].endIndex - 1)
        node.outputEdge.forEach { currentOutputEdge.insert($0) }
    }
    
    return (layoutGraph, positions)
}


fileprivate func adjustEdgeWeight(_ layoutGraph: inout [LayoutGraph.Rank], path: inout [Node.ID: LayoutGraph.Path]) {
    
    for rankIndex in layoutGraph.indices {
        guard rankIndex != 0 else {
            continue
        }
        
        let currentRank = layoutGraph[rankIndex]

        layoutGraph[rankIndex] = currentRank
            .enumerated()
            .map { (levelIndex, node) in
                let weight = node.inputEdge.reduce(0) { partialResult, input in
                    partialResult + (path[input.from]?.level ?? 0)
                }
                return (levelIndex, weight)
            }
            .sorted { $0.1 < $1.1 }.enumerated()
            .map { (levelIndex: Int, arg1: (Int, Int)) -> Node in
                let (i, _) = arg1
                let node = currentRank[i]
                path[node.id] = LayoutGraph.Path(rank: rankIndex, level: levelIndex)
                return node
            }
    }
    
}
