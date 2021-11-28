//
//  Node.swift
//  InteractGraph
//
//  Created by lim on 28/11/2021.
//

import SwiftUI

public struct Node: GraphStorageNode {

    public let id: ID
    
    public let label: String
    
    public let borderColor: Color?
    
    public let dashed: Bool
    
    public init(id: ID, label: String, borderColor: Color? = nil, dashed: Bool = false) {
        self.id = id
        self.label = label
        self.borderColor = borderColor
        self.dashed = dashed
    }
    
    public struct ID: RawRepresentable, ExpressibleByIntegerLiteral, Hashable {
        
        public let rawValue: UInt64
        
        public init(_ rawValue: UInt64) {
            self.rawValue = rawValue
        }

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
        
        public init(integerLiteral value: UInt64) {
            self.rawValue = value
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
