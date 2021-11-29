//
//  AdjacencyListGraph.swift
//  InteractGraph
//
//  Created by limchihi on 21/11/2021.
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

internal protocol AdjacencyListIndexPath {
    
    var row: Int { get }
    
    var column: Int { get }
    
    init(_ indexPath: AdjacencyListIndexPath)
    
}

internal struct AdjacencyListGraph<Element>: Collection {
    
    internal typealias Row = [Element]

    internal private(set) var storage: [Row]
    
    internal init(_ storage: [[Element]]) {
        self.storage = storage
    }
    
    internal var startIndex: Int {
        storage.startIndex
    }
    
    internal var endIndex: Int {
        storage.endIndex
    }
    
    internal subscript(indexPath: AdjacencyListIndexPath) -> Element {
        get {
            storage[indexPath.row][indexPath.column]
        }
        set {
            storage[indexPath.row][indexPath.column] = newValue
        }
    }
    
    subscript(bounds: Range<Int>) -> ArraySlice<[Element]> {
        storage[bounds]
    }

    internal subscript(position: Int) -> [Element] {
        get {
            storage[position]
        }
        set {
            storage[position] = newValue
        }
    }
    
    internal mutating func appendElement(_ element: Element, in row: Int) -> AdjacencyListIndexPath {
        storage[row].append(element)
        return IndexPath(row: row, column: storage[row].endIndex - 1)
    }
    
    internal mutating func appendElementAtLast(_ element: Element) -> AdjacencyListIndexPath {
        let row = storage.endIndex - 1
        storage[row].append(element)
        return IndexPath(row: row, column: storage[row].endIndex - 1)
    }
    
    internal mutating func appendElementAtNewRow(_ element: Element) -> AdjacencyListIndexPath {
        storage.append([element])
        return IndexPath(row: storage.endIndex - 1, column: 0)
    }
    
    internal mutating func forEachUpdate(_ body: (inout Element) throws -> ()) rethrows {
        for row in storage.indices {
            for column in storage[row].indices {
                try body(&storage[row][column])
            }
        }
    }
    
    @discardableResult
    internal mutating func remove(at indexPath: IndexPath) -> Element {
        storage[indexPath.row].remove(at: indexPath.column)
    }
    
    internal func flatForEach(_ block: (Element) throws -> ()) rethrows {
        try storage.forEach { try $0.forEach { try block($0) }}
    }
    
    internal func flatForEach(_ block: (Element, IndexPath, inout Bool) throws -> ()) rethrows {
        var stop = false
        for row in storage.indices {
            for column in storage[row].indices {
                try block(storage[row][column], IndexPath(row: row, column: column), &stop)
                if stop {
                    return
                }
            }
        }
    }

    internal func flatMap<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        try storage.reduce([]) { partialResult, next in
            try partialResult + next.map {
                try transform($0)
            }
        }
    }
    
    internal func flatCompactMap<T>(removeEmptyRow: Bool = true, _ transform: (Element) throws -> T?) rethrows -> AdjacencyListGraph<T> {
        let newStorage = try storage.compactMap { elements -> [T]? in
            let newRow = try elements.compactMap { try transform($0) }
            return removeEmptyRow && newRow.isEmpty ? nil : newRow
        }
        
        return AdjacencyListGraph<T>(newStorage)
    }
 
    internal func index(after i: Int) -> Int {
        i + 1
    }
    
    internal struct IndexPath: AdjacencyListIndexPath {
        
        internal let row: Int
        
        internal let column: Int
        
        internal init(row: Int, column: Int) {
            self.row = row
            self.column = column
        }
        
        internal init(_ indexPath: AdjacencyListIndexPath) {
            self.row = indexPath.row
            self.column = indexPath.column
        }
        
    }
    
}


extension AdjacencyListGraph where Element: Identifiable {
    
    internal func firstIndex(_ id: Element.ID) -> IndexPath? {
        var result: IndexPath?
        flatForEach { element, indexPath, stop in
            if element.id == id {
                result = indexPath
            }
        }
        return result
    }
    
    internal func first(_ id: Element.ID) -> Element? {
        var result: Element?
        flatForEach { element, indexPath, stop in
            if element.id == id {
                result = element
            }
        }
        return result
    }
    
    internal subscript(id: Element.ID) -> Element? {
        get {
            first(id)
        }
        set {
            if let index = firstIndex(id) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    remove(at: index)
                }
            }
        }
    }
    
}
