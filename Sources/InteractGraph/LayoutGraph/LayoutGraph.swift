//
//  LayoutGraph.swift
//  
//
//  Created by lim on 19/11/2021.
//


internal struct LayoutGraph {
    
    internal let storage: AdjacencyListGraph<Node>
    
    internal let path: [Node.ID: LayoutGraphIndexPath]
    
    internal init(_ graph: Graph) {
        var (layoutGraph, path) = longestPath(graph)
        adjustEdgeWeight(&layoutGraph, path: &path)
        self.storage = layoutGraph
        self.path = path
    }
    
    internal init(_ graph: Graph, focusNode: Node.ID) {
        let filterGraph = filter(graph, focusNodeID: focusNode)
        var (layoutGraph, path) = longestPath(filterGraph)
        adjustEdgeWeight(&layoutGraph, path: &path)
        self.storage = layoutGraph
        self.path = path
    }
    
}


fileprivate func longestPath(_ graph: Graph) -> (layoutGraph: AdjacencyListGraph<Node>, path: [Node.ID: LayoutGraphIndexPath]) {
    
    var path: [Node.ID: LayoutGraphIndexPath] = [:]
    
    var layoutGraph = AdjacencyListGraph<Node>([[]])
    
    var currentOutputEdge = Set<OutputEdge>()
    
    for node in graph.nodes {
        
        let indexPath: AdjacencyListIndexPath
        if currentOutputEdge.contains(where: { node.id == $0.to } ) {
            indexPath = layoutGraph.appendElementAtNewRow(node)
            currentOutputEdge.removeAll()
        } else {
            indexPath = layoutGraph.appendElementAtLast(node)
        }
        
        
        path[node.id] = LayoutGraphIndexPath(indexPath)
        node.outputEdge.forEach { currentOutputEdge.insert($0) }
    }
    
    return (layoutGraph, path)
}


fileprivate func filter(_ graph: Graph, focusNodeID: Node.ID) -> Graph {
    
    guard let focusNode = graph.node(id: focusNodeID) else {
        preconditionFailure()
    }
    
    var releatedNodes: Set<Node> = []
    var releatedEdges: Set<Edge> = []
    
    var stack: [Node] = [focusNode]
    
    // inputs
    while let node = stack.popLast() {
        releatedNodes.insert(Node(id: node.id))
        
        for input in node.inputEdge {
            guard !releatedNodes.contains(where: { $0.id == input.from}) &&
                    !stack.contains(where: { $0.id == input.from }) else {
                continue
            }
            releatedEdges.insert(Edge(from: input.from, to: node.id))
            guard let inputNode = graph.node(id: input.from) else {
                preconditionFailure()
            }
            stack.append(inputNode)
        }
    }
    
    // outputs
    stack = [focusNode]
    while let node = stack.popLast() {
        releatedNodes.insert(Node(id: node.id))

        for output in node.outputEdge {
            guard !releatedNodes.contains(where: { $0.id == output.to}) &&
                    !stack.contains(where: { $0.id == output.to }) else {
                        continue
                    }
            
            releatedEdges.insert(Edge(from: node.id, to: output.to))
            guard let outputNode = graph.node(id: output.to) else {
                preconditionFailure()
            }
            stack.append(outputNode)
        }
    }
    
    let newGraph = Graph()
    newGraph.addNodes(Array(releatedNodes).sorted(by: { $0.id < $1.id }))
    newGraph.addEdges(releatedEdges)
    
    return newGraph
}


fileprivate func adjustEdgeWeight(_ layoutGraph: inout AdjacencyListGraph<Node>, path: inout [Node.ID: LayoutGraphIndexPath]) {
    
    for rankIndex in layoutGraph.storage.indices {
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
                path[node.id] = LayoutGraphIndexPath(rank: rankIndex, level: levelIndex)
                return node
            }
    }
    
}
