//
//  Edge.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//

import SwiftUI

public struct Edge {

    public let from: Node.ID
    
    public let to: Node.ID
    
    internal let directed: Bool
    
    internal let attribute: Attribute
    
    public init(from: Node.ID, to: Node.ID) {
        self.from = from
        self.to = to
        self.directed = true
        self.attribute = Attribute(color: nil)
    }
    
    public init(from fromNode: Node, to toNode: Node) {
        self.from = fromNode.id
        self.to = toNode.id
        self.directed = true
        self.attribute = Attribute(color: nil)
    }
    
    internal struct Attribute {
        
        internal let color: Color?
        
    }
    
}

extension Edge: Hashable {
    
    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        lhs.from == rhs.from && lhs.to == rhs.to
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(from)
        hasher.combine(to)
    }
    
}

extension Edge: CustomStringConvertible {
    
    public var description: String {
        "Edge: [\(from) -> \(to)]"
    }
    
}

extension Edge: Identifiable {
    
    public var id: Self {
        self
    }
    
}
