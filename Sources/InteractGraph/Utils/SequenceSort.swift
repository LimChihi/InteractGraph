//
//  SequenceSort.swift
//  InteractGraph
//
//  Created by limchihi on 24/12/2021.
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

extension Sequence {
    
    internal func minimum<T: Comparable>(compareValue transform: (Element) throws -> T?) rethrows -> Element? {
        try sortedFirst(by: <, transform)
    }
    
    internal func maximum<T: Comparable>(compareValue transform: (Element) throws -> T?) rethrows -> Element? {
        try sortedFirst(by: >, transform)
    }
    
    @inlinable
    internal func sortedFirst<T: Comparable>(by areInIncreasingOrder: (T, T) throws -> Bool, _ transform: (Element) throws -> T?) rethrows -> Element? {
        try compactMap { e -> (Element, T)? in
            guard let transformElement = try transform(e) else {
                return nil
            }
            return (e, transformElement)
        }.sorted { lhs, rhs in
            try areInIncreasingOrder(lhs.1, rhs.1)
        }.first?.0
    }
    
}
