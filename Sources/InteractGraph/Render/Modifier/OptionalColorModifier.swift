//
//  File.swift
//  
//
//  Created by lim on 28/11/2021.
//

import SwiftUI


extension View {
    
    internal func optionalForegroundColor(_ color: Color?) -> some View {
        modifier(ForegroundColor(foregroundColor: color))
    }
    
}



fileprivate struct ForegroundColor: ViewModifier {
    
    fileprivate let foregroundColor: Color?
    
    fileprivate func body(content: Content) -> some View {
        if let foregroundColor = foregroundColor {
            content
                .foregroundColor(foregroundColor)
        } else {
            content
        }
    }
    
}
