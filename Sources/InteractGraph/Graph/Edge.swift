//
//  Edge.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//


public struct Edge: Equatable {

    internal let from: Node.ID
    
    internal let to: Node.ID
    
    public init(from: Node.ID, to: Node.ID) {
        self.from = from
        self.to = to
    }
    
}
