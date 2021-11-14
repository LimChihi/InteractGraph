//
//  LabelModifier.swift
//  InteractGraph
//
//  Created by lim on 15/11/2021.
//

import SwiftUI

extension View {
    
    internal func label(_ string: String) -> some View {
        modifier(Label(label: string))
    }
    
}


fileprivate struct Label: ViewModifier {
    
    fileprivate let label: String
    
    fileprivate func body(content: Content) -> some View {
        ZStack {
            content
            Text(label)
                .foregroundColor(.white)
        }
    }
    
}
