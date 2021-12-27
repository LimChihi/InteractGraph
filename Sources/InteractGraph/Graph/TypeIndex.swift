//
//  TypeIndex.swift
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


internal struct TypeIndex<T>: RawInitable, ExpressibleByIntegerLiteral, Hashable, Identifiable, Comparable, Codable {
    
    internal let rawValue: Int
    
    @inlinable
    internal init(_ rawValue: Int) {
        self.rawValue = rawValue
    }

    @inlinable
    internal init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    @inlinable
    internal init(integerLiteral value: Int) {
        self.rawValue = value
    }
    
    @inlinable
    internal var id: RawValue {
        rawValue
    }
    
    @inline(__always)
    internal func cast<NewType>() -> TypeIndex<NewType> {
        TypeIndex<NewType>(rawValue)
    }
    
    @inlinable
    internal static func < (lhs: TypeIndex<T>, rhs: TypeIndex<T>) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

}


extension Array {
    
    internal subscript<T>(index: TypeIndex<T>) -> Element {
        get {
            self[index.rawValue]
        }
        set {
            self[index.rawValue] = newValue
        }
    }
    
}


extension ContiguousArray {
    
    internal subscript<T>(index: TypeIndex<T>) -> Element {
        get {
            self[index.rawValue]
        }
        set {
            self[index.rawValue] = newValue
        }
    }
    
}
