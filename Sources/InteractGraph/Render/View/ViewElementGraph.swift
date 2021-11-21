//
//  ViewElementGraph.swift
//  
//
//  Created by lim on 19/11/2021.
//

import CoreGraphics

internal struct ViewElementGraph {
    
    internal let storage: AdjacencyListGraph<LevelElement>
    
    internal init(_ graph: LayoutGraph) {
        
        var storage = convertNodeToViewElement(graph)
        addEdgeElemetn(graph: &storage, nodePaths: graph.path)
        self.storage = storage
    }
    
    internal struct LevelElement {
        
        internal let element: Element
        
        internal var frame: CGRect
        
    }
    
    
    internal enum Element {
        
        case node(Node)
        
        case edge(Edge)
        
//        case gap
        
    }
    
}


fileprivate func convertNodeToViewElement(_ graph: LayoutGraph) -> AdjacencyListGraph<ViewElementGraph.LevelElement> {
    
    var y: CGFloat = 0
    
    let result: [[ViewElementGraph.LevelElement]] = graph.storage.map { level in
        var x: CGFloat = 0
        
        let result: [ViewElementGraph.LevelElement] = level.map { node in
            let width = calculateWidth(for: .node(node))
            x += width
            
            return ViewElementGraph.LevelElement(element: .node(node), frame: CGRect(x: x, y: y, width: width, height: elementHeight))
        }
        
        y += (elementHeight + rankGap)
        return result
    }
    
    return AdjacencyListGraph<ViewElementGraph.LevelElement>(storage: result)
}


fileprivate func addEdgeElemetn(graph: inout AdjacencyListGraph<ViewElementGraph.LevelElement>, nodePaths: [Node.ID: LayoutGraphIndexPath]) {
    
    var nodePaths = nodePaths
    for rankIndex in graph.indices {
        for levelIndex in graph[rankIndex].indices {
            if case let .node(node) = graph[LayoutGraphIndexPath(rank: rankIndex, level: levelIndex)].element {
                for outputEdge in node.outputEdge {
                    let edge = Edge(from: node.id, to: outputEdge.to)
                    let newPaths = passByPaths(from: nodePaths[node.id]!, to: nodePaths[outputEdge.to]!, in: graph)
                    for path in newPaths {
                        let x = graph[path.rank].count != 0 ? graph[path].frame.minX : 0
                        let y = graph[path.rank].first!.frame.minY
                        let newFrame = CGRect(x: x, y: y, width: edgeWidth, height: elementHeight)
                        graph[path.rank].insert(ViewElementGraph.LevelElement(element: .edge(edge), frame: newFrame), at: path.level)
                        
                        if graph[path.rank].count > path.rank + 1 {
                            for newlevelIndex in path.rank + 1..<graph[path.rank].endIndex {
                                graph[path.rank][newlevelIndex].frame.origin.x += newFrame.origin.x
                                if case let .node(node) = graph[path.rank][newlevelIndex].element {
                                    nodePaths[node.id]?.level += 1
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


fileprivate func passByPaths(from fromNodePath: LayoutGraphIndexPath, to toNodePath: LayoutGraphIndexPath, in viewElementGraph: AdjacencyListGraph<ViewElementGraph.LevelElement>) -> [LayoutGraphIndexPath] {
    
    let rankDiff = abs(fromNodePath.rank - toNodePath.rank)
    guard rankDiff > 1 else {
        return []
    }
    
    let fromNodeCenter = viewElementGraph[fromNodePath.rank][fromNodePath.level].frame.center
    let toNodeCenter = viewElementGraph[toNodePath.rank][toNodePath.level].frame.center
    
    // y = kx + b
    //k = (y1 - y2) / (x1 - x2)
    let k = (fromNodeCenter.y - toNodeCenter.y) / Double(fromNodeCenter.x - toNodeCenter.x)
    // b = y - kx
    let b = fromNodeCenter.y - k * fromNodeCenter.x
    
    var passByPaths: [LayoutGraphIndexPath] = []
    passByPaths.reserveCapacity(rankDiff)
    let minRank = min(fromNodePath.rank, toNodePath.rank)
    
    for rankIndex in minRank..<(minRank + rankDiff) {
        
        let y = Double(rankIndex) * (elementHeight + rankGap) + elementHeight / 2
        let x = (y - b) / k
        
        var insertLevel = viewElementGraph[rankIndex].count
        
        for levelIndex in 1..<viewElementGraph[rankIndex].endIndex where x < viewElementGraph[rankIndex][levelIndex].frame.minX {
            insertLevel = levelIndex
            break
        }
        
        passByPaths.append(LayoutGraphIndexPath(rank: rankIndex, level: insertLevel))
    }
    
    return passByPaths
}

fileprivate func calculateWidth(for element: ViewElementGraph.Element) -> CGFloat {
    switch element {
    case .node(let node):
        return calculateWidth(for: node)
    case .edge:
        return 30
    }
}

fileprivate func calculateWidth(for node: Node) -> CGFloat {
    nodeWidth // TODO: long label
}


fileprivate let nodeWidth: Double = 50
fileprivate let elementHeight: Double = 50

fileprivate let edgeWidth: Double = 10

fileprivate let rankGap: Double = 50
fileprivate let levelGap: Double = 50
