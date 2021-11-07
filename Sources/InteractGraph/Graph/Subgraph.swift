//
//  Subgraph.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//


internal struct Subgraph {

    private unowned let graph: Graph
    
    private var nodes: [Node]
    
    private var edges: [Edge]
    
    internal init(graph: Graph, nodes: [Node], edges: [Edge]) {
        self.graph = graph
        self.nodes = nodes
        self.edges = edges
    }
    
}
