//
//  Node.swift
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

public struct Node: GraphStorageNode {

    public let id: ID
    
    public let label: String
    
    public let shape: Shape
    
    public let borderColor: Color?
    
    public let dashed: Bool
    
    public init(id: ID, label: String, shape: Shape = .ellipse, borderColor: Color? = nil, dashed: Bool = false) {
        self.id = id
        self.label = label
        self.shape = shape
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
    
    public enum Shape {
        case ellipse
        case rectangle
        case roundedRectangle
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
