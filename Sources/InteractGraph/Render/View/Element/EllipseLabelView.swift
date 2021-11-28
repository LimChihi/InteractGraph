//
//  EllipseLabelView.swift
//  InteractGraph
//
//  Created by lim on 22/11/2021.
//

import SwiftUI

internal struct EllipseLabelView: View {
    
    private let node: Node
    
    internal init(node: Node) {
        self.node = node
    }
    
    internal var body: some View {
        Ellipse()
            .stroke(style: StrokeStyle(lineWidth: 2, dash: node.dashed ? [5] : []))
            .optionalForegroundColor(node.borderColor)
            .label(node.label)
    }
}

struct EllipseLabelView_Previews: PreviewProvider {
    static var previews: some View {
        EllipseLabelView(node: .init(id: 1, label: "Hello", borderColor: .blue, dashed: false))
    }
}
