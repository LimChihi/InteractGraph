//
//  EllipseLabelView.swift
//  
//
//  Created by lim on 22/11/2021.
//

import SwiftUI

internal struct EllipseLabelView: View {
    
    private let attribute: Node.Attribute
    
    internal init(attribute: Node.Attribute) {
        self.attribute = attribute
    }
    
    internal var body: some View {
        Ellipse()
            .stroke(style: StrokeStyle(dash: attribute.dashed ? [5] : []))
            .foregroundColor(attribute.borderColor)
            .label(attribute.label)
    }
}

struct EllipseLabelView_Previews: PreviewProvider {
    static var previews: some View {
        EllipseLabelView(attribute: .init(label: "Hello", borderColor: .blue, dashed: false))
    }
}
