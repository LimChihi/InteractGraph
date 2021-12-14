//
//  NodeView.swift
//  InteractGraph
//
//  Created by limchihi on 1/12/2021.
//
//  Copyright (c) 2021 Lin Zhiyi <limchihi@foxmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SwiftUI

internal struct NodeView: View {
    
    private let nodeAttribute: Node.Attribute
    
    internal init(node: Node.Attribute) {
        self.nodeAttribute = node
    }
    
    internal var body: some View {
        Group {
            let style = StrokeStyle(lineWidth: 2, dash: nodeAttribute.dashed ? [5] : [])
            switch nodeAttribute.shape {
            case .ellipse:
                Ellipse()
                    .stroke(style: style)
            case .rectangle:
                Rectangle()
                    .stroke(style: style)
            case .roundedRectangle:
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(style: style)
            }
        }
        .optionalForegroundColor(nodeAttribute.borderColor)
        .label(nodeAttribute.label)
    }
    
}


struct NodeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NodeView(node: .init(label: "hello1", shape: .ellipse, borderColor: .blue, dashed: false))
            NodeView(node: .init(label: "hello2", shape: .rectangle, borderColor: .blue, dashed: true))
            NodeView(node: .init(label: "hello3", shape: .roundedRectangle, borderColor: .red, dashed: false))
        }
        .padding(20)
    }
}
