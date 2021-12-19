//
//  OptionalElementArray.swift
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
   

internal struct OptionalElementArray<Element>: RandomAccessCollection, RangeReplaceableCollection, ExpressibleByArrayLiteral, MutableCollection, BidirectionalCollection {
    
    internal typealias ArrayLiteralElement = Element

    internal typealias Index = TypeIndex<Element>
    
    private var elements: ContiguousArray<Element?>
    
    private var emptySlots: Set<Int>
    
    @inlinable
    internal init() {
        self.elements = []
        self.emptySlots = []
    }
    
    @inlinable
    init(arrayLiteral elements: Element...) {
        self.elements = ContiguousArray(elements)
        self.emptySlots = []
    }
    
    @inlinable
    internal var count: Int {
        elements.count - emptySlots.count
    }
    
    @inlinable
    internal var startIndex: TypeIndex<Element> {
        TypeIndex(
            (0..<elements.count).first {
                !emptySlots.contains($0)
            } ?? 0
        )
    }
    
    @inlinable
    internal var endIndex: TypeIndex<Element> {
        TypeIndex(
            ((0..<elements.count).reversed().first {
                !emptySlots.contains($0)
            } ?? 0) + 1
        )
    }
    
    @inlinable
    internal subscript(position: TypeIndex<Element>) -> Element {
        get {
            elements[position]!
        }
        set {
            elements[position] = newValue
            if let index = emptySlots.firstIndex(of: position.rawValue) {
                emptySlots.remove(at: index)
            }
        }
    }
    
    @inlinable
    @discardableResult
    internal mutating func append(_ newElement: Element) -> Index {
        if let index = emptySlots.popFirst() {
            elements[index] = newElement
            return Index(index)
        } else {
            let index = elements.endIndex
            elements.append(newElement)
            return Index(index)
        }
    }
    
    @inlinable
    @discardableResult
    internal mutating func append<S: Sequence>(contentsOf newElements: S) -> ContiguousArray<Index> where S.Element == Element {
        // ContiguousArray will created Contiguous Buff for new Elements.
        let start = elements.endIndex
        elements.append(contentsOf: Array(newElements))
        let end = elements.endIndex
        return ContiguousArray<Index>((start..<end).map { Index($0) })
    }
    
    @inlinable
    internal func insert(_ newElement: Element, at i: TypeIndex<Element>) {
        fatalError()
    }
    
    @inlinable
    internal func insert<S>(contentsOf newElements: S, at i: TypeIndex<Element>) where S : Collection, Element == S.Element {
        fatalError()
    }
    
    @inlinable
    internal func replaceSubrange<C>(_ subrange: Range<TypeIndex<Element>>, with newElements: C) where C : Collection, Element == C.Element {
        fatalError()
    }
    
    @inlinable
    internal func removeFirst() -> Element {
        fatalError()
    }
    
    @inlinable
    internal func removeFirst(_ k: Int) {
        fatalError()
    }
    
    @inlinable
    internal mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        if keepCapacity {
            emptySlots = Set(0..<elements.count)
            elements.removeAll(keepingCapacity: true)
        } else {
            elements = []
            emptySlots = []
        }
    }
    
    @inlinable
    @discardableResult
    internal mutating func remove(at i: TypeIndex<Element>) -> Element {
        emptySlots.insert(i.rawValue)
        let e = elements[i.rawValue]
        elements[i.rawValue] = nil
        return e!
    }
    
    @inlinable
    internal func removeSubrange(_ bounds: Range<TypeIndex<Element>>) {
        fatalError()
    }
    
    @inlinable
    internal mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try indices.filter {
            try shouldBeRemoved(self[$0])
        }
        .sorted(by: >)
        .forEach {
            emptySlots.insert($0.rawValue)
            elements[$0.rawValue] = nil
        }
    }
    
    @inlinable
    internal mutating func reserveCapacity(_ n: Int) {
        elements.reserveCapacity(n)
    }
    
    @inlinable
    internal mutating func popLast() -> Element? {
        guard count > 0 else {
            return nil
        }
        emptySlots.insert(endIndex.rawValue)
        return elements.popLast()!
    }
    
    @inlinable
    internal func index(before i: TypeIndex<Element>) -> TypeIndex<Element> {
        var index = i - 1
        while emptySlots.contains(index.rawValue) {
            index -= 1
        }
        return index
    }
    
    @inlinable
    internal func index(after i: TypeIndex<Element>) -> TypeIndex<Element> {
        var index = i + 1
        while emptySlots.contains(index.rawValue) {
            index += 1
        }
        return index
    }
}
