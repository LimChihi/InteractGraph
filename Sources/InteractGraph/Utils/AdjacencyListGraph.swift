//
//  AdjacencyListGraph.swift
//  
//
//  Created by lim on 21/11/2021.
//


internal protocol AdjacencyListIndexPath {
    
    var row: Int { get }
    
    var column: Int { get }
    
    init(_ indexPath: AdjacencyListIndexPath)
    
}

internal struct AdjacencyListGraph<Element>: Collection {

    internal var storage: [[Element]]
    
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
    
    internal func flatForEach(_ block: (Element) throws -> ()) rethrows {
        try storage.forEach { try $0.forEach { try block($0) }}
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
        
        return AdjacencyListGraph<T>(storage: newStorage)
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