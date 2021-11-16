//
//  NodeLayering.swift
//  
//
//  Created by limchihi on 9/11/2021.
//

import Foundation

extension Graph {
    
    internal typealias NodeLayer = [[Node]]
     
    internal func nodeLayering() -> NodeLayer {
        var (layoutGraph, positions) = longestPath(self)
        adjustWeight(&layoutGraph, positions: positions)
        return layoutGraph
    }
    
}


fileprivate func longestPath(_ graph: Graph) -> (Graph.NodeLayer, [Node.ID: NodePosition]) {
    
    var positions: [Node.ID: NodePosition] = [:]
    
    var layoutGraph: Graph.NodeLayer = [[]]
    
    var currentOutputEdge = Set<OutputEdge>()
    
    for node in graph.nodes {
        if currentOutputEdge.contains(where: { node.id == $0.to } ) {
            layoutGraph.append([node])
            currentOutputEdge.removeAll()
        } else {
            layoutGraph[layoutGraph.endIndex - 1].append(node)
        }
        positions[node.id] = NodePosition(rank: layoutGraph.endIndex - 1, level: layoutGraph[layoutGraph.endIndex - 1].endIndex - 1)
        node.outputEdge.forEach { currentOutputEdge.insert($0) }
    }
    
    return (layoutGraph, positions)
}


fileprivate func adjustWeight(_ layoutGraph: inout Graph.NodeLayer, positions: [Node.ID: NodePosition]) {
    
    for rankIndex in layoutGraph.indices {
        guard rankIndex != 0 else {
            continue
        }
        
        let currentRank = layoutGraph[rankIndex]

        layoutGraph[rankIndex] = currentRank
            .enumerated()
            .map { (levelIndex, node) in
                let weight = node.inputEdge.reduce(0) { partialResult, input in
                    partialResult + (positions[input.from]?.level ?? 0)
                }
                return (levelIndex, weight)
            }
            .sorted { $0.1 < $1.1 }
            .map { (i: Int, _: Int) -> Node in
                currentRank[i]
            }
    }
    
}
