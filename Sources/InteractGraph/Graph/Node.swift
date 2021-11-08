//
//  Node.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//


public struct Node: Hashable {
    
    public typealias ID = UInt64

    internal let id: ID
    
    internal var inputEdge: [InputEdge]
    
    internal var outputEdge: [OutputEdge]
    
    public init(id: UInt64) {
        self.id = id
        self.inputEdge = []
        self.outputEdge = []
    }
    
}
