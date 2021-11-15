//
//  Edge.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//


public struct Edge: Hashable {

    internal let from: Node.ID
    
    internal let to: Node.ID
    
    public init(from: Node.ID, to: Node.ID) {
        self.from = from
        self.to = to
    }
    
    public init(from fromNode: Node, to toNode: Node) {
        self.from = fromNode.id
        self.to = toNode.id
    }
    
}

extension Edge: Identifiable {
    
    public var id: Self {
        self
    }
    
}
