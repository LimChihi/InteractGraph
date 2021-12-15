//
//  RawInitable.swift
//  InteractGraph
//
//  Created by limchihi on 15/12/2021.
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

   
internal protocol RawInitable: RawRepresentable {
    
    associatedtype RawValue
    
    init(_ rawValue: RawValue)
}


extension RawInitable where RawValue: AdditiveArithmetic {
    
    internal static func + (lhs: Self, rhs: Self) -> Self {
        self.init(lhs.rawValue + rhs.rawValue)
    }
    
    internal static func + (lhs: Self, rhs: RawValue) -> Self {
        self.init(lhs.rawValue + rhs)
    }
    
    internal static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    internal static func += (lhs: inout Self, rhs: RawValue) {
        lhs = lhs + rhs
    }
    
    internal static func - (lhs: Self, rhs: Self) -> Self {
        return self.init(lhs.rawValue - rhs.rawValue)
    }
    
    internal static func - (lhs: Self, rhs: RawValue) -> Self {
        self.init(lhs.rawValue - rhs)
    }
    
    internal static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    internal static func -= (lhs: inout Self, rhs: RawValue) {
        lhs = lhs - rhs
    }
    
}
