//
//  Graph.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//


public class Graph {
    
    private let directed: Bool
    
    private let strict: Bool
    
    private var subgraphs: [Subgraph]
    
    private var nodes: [Node]
    
    private var edges: [Edge]
    
    internal init(directed: Bool = true, strict: Bool = true) {
        self.directed = directed
        self.strict = strict
        self.subgraphs = []
        self.nodes = []
        self.edges = []
    }
    
}
