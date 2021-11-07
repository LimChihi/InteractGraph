//
//  Node.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//


internal struct Node: Identifiable, Equatable {

    internal let id: UInt64
    
    internal init(id: UInt64) {
        self.id = id
    }
    
}
