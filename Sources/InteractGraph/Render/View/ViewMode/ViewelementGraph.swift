//
//  ViewElementGraph.swift
//  InteractGraph
//
//  Created by lim on 29/11/2021.
//

import CoreGraphics

internal struct ViewElementGraph {
    
    internal let raw: Graph
    
    internal private(set) var storage: AdjacencyListGraph<ViewElement>

    internal init(_ graph: Graph) {
        self.raw = graph
        self.storage = generateStorage(graph: graph, focusNode: nil)
    }
    
    internal mutating func setFocusNode(_ focusNode: NodeIndex) {
        storage = generateStorage(graph: raw, focusNode: focusNode)
    }
    
    internal mutating func removeFocusNode() {
        storage = generateStorage(graph: raw, focusNode: nil)
    }
    
    internal struct ViewElement: Hashable, Identifiable {
        
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
        
        case node(NodeIndex)
        
        case edge(EdgeIndex)
        
    }
    
}


fileprivate typealias LevelElement = ViewElementGraph.ViewElement


fileprivate func generateStorage(graph: Graph, focusNode: NodeIndex?) -> AdjacencyListGraph<LevelElement> {
    let layoutGraph = LayoutGraph(graph, focusNode: focusNode)
    var storage = convertNodeToViewElement(layoutGraph, graph: graph)
    addEdgeElemetn(&storage, layoutGraph: layoutGraph, graph: graph)
    return storage
}

fileprivate func convertNodeToViewElement(_ layoutGraph: LayoutGraph, graph: Graph) -> AdjacencyListGraph<LevelElement> {
    
    var y: CGFloat = 0
    
    let result: [[LevelElement]] = layoutGraph.storage.map { level in
        var x: CGFloat = 0
        
        let result: [LevelElement] = level.map { node in
            let width = calculateWidth(for: .node(node), in: graph)
            
            let element = LevelElement(
                element: .node(node),
                frame: CGRect(x: x, y: y, width: width, height: elementHeight))
            
            x += (width + levelGap)
            return element
        }
        
        y += (elementHeight + rankGap)
        return result
    }
    
    return AdjacencyListGraph<LevelElement>(result)
}


fileprivate func addEdgeElemetn(_ storage: inout AdjacencyListGraph<LevelElement>, layoutGraph: LayoutGraph, graph: Graph) {
    
    var nodePaths = layoutGraph.path
    storage.flatForEach { viewElement, indexPath, _ in
        guard case let .node(nodeIndex) = viewElement.element else {
            return
        }
        
        for outputIndex in graph.outputEdges(for: nodeIndex) {
            if let releatedNodes = layoutGraph.releatedNodes, !releatedNodes.contains(outputIndex) {
                continue
            }
            
            let edgeIndex = graph.edgeIndex(from: nodeIndex, to: outputIndex)!
            let newPaths = edgePassByPaths(from: nodePaths[nodeIndex]!, to: nodePaths[outputIndex]!, in: storage)
            for path in newPaths {
                let preNodeFrame = storage[path.rank].count != path.level ? storage[path].frame : nil
                let x = preNodeFrame?.minX ?? (storage[path.rank].last!.frame.maxX + levelGap)
                let y = preNodeFrame?.minY ?? storage[path.rank].first!.frame.minY
                let newFrame = CGRect(x: x, y: y, width: edgeWidth, height: elementHeight)
                storage[path.rank].insert(LevelElement(element: .edge(edgeIndex), frame: newFrame), at: path.level)
                
                guard storage[path.rank].count > path.rank + 1 else {
                    continue
                }
                for newlevelIndex in path.rank + 1..<storage[path.rank].endIndex {
                    storage[path.rank][newlevelIndex].frame.origin.x += newFrame.origin.x
                    if case let .node(nodeIndex) = storage[path.rank][newlevelIndex].element {
                        nodePaths[nodeIndex]?.level += 1
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
    
    let (k, b) = fromNodeCenter.slopeFormula(toNodeCenter)
    
    var passByPaths: [LayoutGraphIndexPath] = []
    passByPaths.reserveCapacity(rankDiff)
    let minRank = min(fromNodePath.rank, toNodePath.rank)
    
    for rankIndex in minRank + 1..<(minRank + rankDiff) {
        
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


fileprivate func calculateWidth(for element: ViewElementGraph.Element, in graph: Graph) -> CGFloat {
    switch element {
    case .node(let node):
        return calculateWidth(for: node, in: graph)
    case .edge:
        return 30
    }
}

fileprivate func calculateWidth(for node: NodeIndex, in graph: Graph) -> CGFloat {
    nodeWidth // TODO: long label
}


fileprivate let nodeWidth: CGFloat = 200
fileprivate let elementHeight: CGFloat = 100

fileprivate let edgeWidth: CGFloat = 15

fileprivate let rankGap: CGFloat = 50
fileprivate let levelGap: CGFloat = 50
