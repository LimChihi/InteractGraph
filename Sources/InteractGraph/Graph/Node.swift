//
//  Node.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//

import SwiftUI

public struct Node {
    
    public typealias ID = UInt64

    internal let id: ID
    
    internal let attribute: Attribute
    
    internal var inputEdge: [InputEdge]
    
    internal var outputEdge: [OutputEdge]
    
    public init(id: ID, label: String, borderColor: Color? = nil, dashed: Bool = false) {
        self.id = id
        self.attribute = Attribute(label: label, borderColor: borderColor, dashed: dashed)
        self.inputEdge = []
        self.outputEdge = []
    }
    
    internal init(id: ID, attribute: Attribute) {
        self.id = id
        self.attribute = attribute
        self.inputEdge = []
        self.outputEdge = []
    }
    
    // FIXME: Remove this
    internal init(id: ID) {
        self.id = id
        self.attribute = .default
        self.inputEdge = []
        self.outputEdge = []
    }
    
    internal struct Attribute {
        
        internal let label: String
        
        internal let borderColor: Color?
        
        internal let dashed: Bool
        
        static var `default`: Attribute {
            Attribute(label: "", borderColor: nil, dashed: false)
        }
        
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
