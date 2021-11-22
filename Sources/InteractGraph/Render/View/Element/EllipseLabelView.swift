//
//  EllipseLabelView.swift
//  
//
//  Created by lim on 22/11/2021.
//

import SwiftUI

internal struct EllipseLabelView: View {
    
    private let label: String
    
    internal init(label: String) {
        self.label = label
    }
    
    internal var body: some View {
        Ellipse()
            .foregroundColor(.blue)
            .label(label)
    }
}

fileprivate struct EllipseLabelView_Previews: PreviewProvider {
    static var previews: some View {
        EllipseLabelView(label: "node")
    }
}
