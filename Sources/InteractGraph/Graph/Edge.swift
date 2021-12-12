//
//  Edge.swift
//  InteractGraph
//
//  Created by limchihi on 28/11/2021.
//
//  Copyright (c) 2021 Lin Zhiyi <limchihi@foxmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SwiftUI

public struct Edge: GraphStorageEdge {

    public let from: Node.ID
    
    public let to: Node.ID
    
    public let color: Color?
    
    public let dashed: Bool
    
    public init(from: Node, to: Node, color: Color? = nil, dashed: Bool = false) {
        self.from = from.id
        self.to = to.id
        self.color = color
        self.dashed = dashed
    }
    
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
