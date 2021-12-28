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

public struct Edge: Hashable {

    public let from: Node.ID
    
    public let to: Node.ID
    
    internal let attribute: Attribute
    
    public init(from: Node, to: Node, color: Color? = nil, dashed: Bool = false) {
        self.from = from.id
        self.to = to.id
        self.attribute = Attribute(color: color, dashed: dashed)
    }
    
    public init(from: Node.ID, to: Node.ID, color: Color? = nil, dashed: Bool = false) {
        self.from = from
        self.to = to
        self.attribute = Attribute(color: color, dashed: dashed)
    }
    
    internal struct Attribute: Hashable {
        
        internal let color: Color?
        
        internal let dashed: Bool
        
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
