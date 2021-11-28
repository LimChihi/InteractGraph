//
//  TypeIndex.swift
//  InteractGraph
//
//  Created by lim on 28/11/2021.
//


public struct TypeIndex<T>: RawRepresentable, ExpressibleByIntegerLiteral, Hashable, Identifiable {
    
    public let rawValue: Int
    
    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
    
    public var id: RawValue {
        rawValue
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
