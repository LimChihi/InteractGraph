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
        var layoutGraph = longestPath(self)
        adjustWeight(&layoutGraph)
        return layoutGraph
    }
    
}


fileprivate func longestPath(_ graph: Graph) -> Graph.NodeLayer {
    
    var layoutGraph: Graph.NodeLayer = [[]]
    
    var currentOutputEdge = Set<OutputEdge>()
    
    for node in graph.nodes {
        if currentOutputEdge.contains(where: { node.id == $0.to } ) {
            layoutGraph.append([node])
            currentOutputEdge.removeAll()
        } else {
            layoutGraph[layoutGraph.endIndex - 1].append(node)
        }
        node.outputEdge.forEach { currentOutputEdge.insert($0) }
    }
    
    return layoutGraph
}


fileprivate func adjustWeight(_ layoutGraph: inout Graph.NodeLayer) {
    
    for index in layoutGraph.indices {
        guard index != 0 else {
            continue
        }
        
        let lastRank = layoutGraph[index - 1]
        let currentRank = layoutGraph[index]

        layoutGraph[index] = currentRank
            .enumerated()
            .map { (index, node) in
                let weight = node.inputEdge.reduce(0) { partialResult, input in
                    partialResult + (lastRank.firstIndex { $0.id == input.from } ?? 0)
                }
                return (index, weight)
            }
            .sorted { $0.1 < $1.1 }
            .map { (i: Int, _: Int) -> Node in
                currentRank[i]
            }
    }
    
}
