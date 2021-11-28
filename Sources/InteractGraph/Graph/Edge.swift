//
//  Edge.swift
//  InteractGraph
//
//  Created by lim on 28/11/2021.
//

import SwiftUI

public struct Edge: GraphStorageEdge {

    public let from: Node.ID
    
    public let to: Node.ID
    
    public let color: Color?
    
    public let dashed: Bool
    
    public init(from: Node.ID, to: Node.ID, color: Color? = nil, dashed: Bool = false) {
        self.from = from
        self.to = to
        self.color = color
        self.dashed = dashed
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


internal struct GraphEdge: Identifiable, Hashable {
    
    internal let index: EdgeIndex
    
    internal let fromNodeIndex: NodeIndex
    
    internal let toNodeIndex: NodeIndex
    
    internal var id: Self {
        self
    }
    
}
