//
//  SequenceIdentifiable.swift
//  
//
//  Created by lim on 27/11/2021.
//


extension Array: Identifiable where Element: Identifiable {
    

}

extension Sequence where Element: Identifiable {
    
    public var id: [Element.ID] {
        map { $0.id }
    }
    
}
