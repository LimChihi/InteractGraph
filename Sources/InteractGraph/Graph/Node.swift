//
//  Node.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//


public struct Node {
    
    public typealias ID = UInt64

    internal let id: ID
    
    internal let attribute: Attribute
    
    internal var inputEdge: [InputEdge]
    
    internal var outputEdge: [OutputEdge]
    
    public init(id: ID, label: String) {
        self.id = id
        self.attribute = Attribute(label: label)
        self.inputEdge = []
        self.outputEdge = []
    }
    
    internal init(id: ID, attribute: Attribute = Attribute(label: "")) {
        self.id = id
        self.attribute = attribute
        self.inputEdge = []
        self.outputEdge = []
    }
    
    internal struct Attribute {
        
        internal let label: String
        
    }
    
}

extension Node: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
