//
//  LayoutGraphIndexPath.swift
//  
//
//  Created by lim on 21/11/2021.
//

internal struct LayoutGraphIndexPath: AdjacencyListIndexPath {

    internal var rank: Int
    
    internal var level: Int
    
    @inlinable
    internal var row: Int {
        rank
    }
    
    @inlinable
    internal var column: Int {
        level
    }
    
    internal init(rank: Int, level: Int) {
        self.rank = rank
        self.level = level
    }
    
    internal init(_ indexPath: AdjacencyListIndexPath) {
        self.rank = indexPath.row
        self.level = indexPath.column
    }
    
}
