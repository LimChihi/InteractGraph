//
//  ViewElementGraph.swift
//  
//
//  Created by lim on 19/11/2021.
//

import CoreGraphics

internal struct ViewElementGraph {
    
    internal let storage: AdjacencyListGraph<LevelElement>
    
    internal let edges: [Edge]
    
    internal let edgesControlPoints: [Edge: [CGPoint]]
    
    internal init(_ graph: LayoutGraph) {
        let edges = getEdges(graph)
        var storage = convertNodeToViewElement(graph)
        addEdgeElemetn(graph: &storage, nodePaths: graph.path)
        let controlPoints = edgesControlPointsForGraph(storage)
        self.storage = storage
        self.edges = edges
        self.edgesControlPoints = controlPoints
    }
    
    internal struct LevelElement: Hashable, Identifiable {
        
        internal let element: Element
        
        internal var frame: CGRect
        
        internal func hash(into hasher: inout Hasher) {
            hasher.combine(element)
        }
        
        var id: Self {
            self
        }
        
    }
    
    
    internal enum Element: Hashable {
        
        case node(Node)
        
        case edge(Edge)
        
//        case gap
        
    }
    
}


fileprivate typealias LevelElement = ViewElementGraph.LevelElement

fileprivate func getEdges(_ graph: LayoutGraph) -> [Edge] {
    let edges = graph.storage.flatMap { node in
        node.outputEdge.map {
            Edge(from: node.id, to: $0.to)
        }
    }
    
    return edges.reduce([]) { partialResult, next in
        partialResult + next
    }
}

fileprivate func convertNodeToViewElement(_ graph: LayoutGraph) -> AdjacencyListGraph<LevelElement> {
    
    var y: CGFloat = 0
    
    let result: [[LevelElement]] = graph.storage.map { level in
        var x: CGFloat = 0
        
        let result: [LevelElement] = level.map { node in
            let width = calculateWidth(for: .node(node))
            
            let element = LevelElement(element: .node(node), frame: CGRect(x: x, y: y, width: width, height: elementHeight))
            x += (width + levelGap)
            return element
        }
        
        y += (elementHeight + rankGap)
        return result
    }
    
    return AdjacencyListGraph<LevelElement>(storage: result)
}


fileprivate func addEdgeElemetn(graph: inout AdjacencyListGraph<LevelElement>, nodePaths: [Node.ID: LayoutGraphIndexPath]) {
    
    var nodePaths = nodePaths
    for rankIndex in graph.indices {
        for levelIndex in graph[rankIndex].indices {
            if case let .node(node) = graph[LayoutGraphIndexPath(rank: rankIndex, level: levelIndex)].element {
                for outputEdge in node.outputEdge {
                    let edge = Edge(from: node.id, to: outputEdge.to)
                    let newPaths = edgePassByPaths(from: nodePaths[node.id]!, to: nodePaths[outputEdge.to]!, in: graph)
                    for path in newPaths {
                        let preNodeFrame = graph[path.rank].count != path.level ? graph[path].frame : nil
                        let x = preNodeFrame?.minX ?? (graph[path.rank].last!.frame.maxX + levelGap)
                        let y = preNodeFrame?.minY ?? graph[path.rank].first!.frame.minY
                        let newFrame = CGRect(x: x, y: y, width: edgeWidth, height: elementHeight)
                        graph[path.rank].insert(LevelElement(element: .edge(edge), frame: newFrame), at: path.level)
                        
                        guard graph[path.rank].count > path.rank + 1 else {
                            continue
                        }
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


fileprivate func edgePassByPaths(from fromNodePath: LayoutGraphIndexPath, to toNodePath: LayoutGraphIndexPath, in viewElementGraph: AdjacencyListGraph<LevelElement>) -> [LayoutGraphIndexPath] {
    
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

fileprivate func edgesControlPointsForGraph(_ graph: AdjacencyListGraph<LevelElement>) -> [Edge: [CGPoint]] {
    var result: [Edge: [CGPoint]] = [:]
    
    graph.flatForEach { levelElement in
        guard case .edge(let edge) = levelElement.element else {
            return
        }
        let point = levelElement.frame.center
        if result.keys.contains(edge) {
            result[edge]?.append(point)
        } else {
            result[edge] = [point]
        }
    }

    return result
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


fileprivate let nodeWidth: CGFloat = 200
fileprivate let elementHeight: CGFloat = 100

fileprivate let edgeWidth: CGFloat = 10

fileprivate let rankGap: CGFloat = 50
fileprivate let levelGap: CGFloat = 50
