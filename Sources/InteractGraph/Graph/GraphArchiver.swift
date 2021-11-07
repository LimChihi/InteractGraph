//
//  GraphArchiver.swift
//  InteractGraph
//
//  Created by limchihi on 8/11/2021.
//

import Foundation

internal class GraphArchiver {
    
    internal var storage: [UUID: [Graph]]
    
    static let shared = GraphArchiver()
    
    private init() {
        storage = [:]
    }
    
    internal func addArchive(graph: Graph) {
        if !storage.keys.contains(where: { graph.id == $0 }) {
            storage[graph.id] = [graph]
        } else {
            storage[graph.id]?.append(graph)
        }
    }
    
    internal func dropAll(id: UUID) {
        storage.removeValue(forKey: id)
    }
    
}
