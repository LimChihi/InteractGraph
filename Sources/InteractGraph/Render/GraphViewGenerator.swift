//
//  GraphViewGenerator.swift
//  
//
//  Created by limchihi on 10/11/2021.
//

import Foundation
/*

public struct GraphViewGenerator {
    
    private let graph: Graph
    
    public init(graph: Graph) {
        self.graph = graph
    }
    
    private func calculateSize(use nodeLayer: Graph.NodeLayer) -> Size {
        // top down
        let rank = nodeLayer.count
        let level = nodeLayer.reduce(0) { max($0, $1.count) }
        
        return Size(width: Double(level + 1) * levelWidth, height: Double(rank + 1) * rankHeight)
    }
    
    private func calculatePosition(use nodeLayer: Graph.NodeLayer, in size: Size) -> [[Position]] {
        var positions: [[Position]] = []
        for layerIndex in nodeLayer.indices {
            
            let level = Double(nodeLayer[layerIndex].count)
            let width = nodeWidth * level + levelGap * (level - 1)
            var currentX = size.width - width
            let currentY = rankGap * Double(layerIndex + 1) + nodeHeight * Double(layerIndex)
            
            var layerPositions: [Position] = []
            for _ in nodeLayer[layerIndex] {
                layerPositions.append(Position(x: currentX, y: currentY))
                currentX += (nodeWidth + levelGap)
            }
            
            positions.append(layerPositions)
        }
        
        return positions
    }
    
}


fileprivate let levelWidth: Double = 100
fileprivate let rankHeight: Double = 100

fileprivate let nodeWidth: Double = 50
fileprivate let nodeHeight: Double = 50

fileprivate let rankGap: Double = rankHeight - nodeHeight
fileprivate let levelGap: Double = levelWidth - nodeHeight

 */
