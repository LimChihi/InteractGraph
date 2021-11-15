//
//  LayoutGraphView.swift
//  
//
//  Created by lim on 15/11/2021.
//

import SwiftUI


internal struct LayoutGraphView: View {
    
    internal let data: Graph.NodeLayer
    
    internal let coordinateSpace: CoordinateSpace
    
    internal let rankGap: CGFloat
    
    internal let levelGap: CGFloat
    
    internal var body: some View {
        LazyVStack(spacing: rankGap) {
            ForEach(data.indices) { index in
                LazyHStack(spacing: levelGap) {
                    ForEach(data[index], id: \.self) { item in
                        GeometryReader { proxy in
                            EllipseLabelView(label: "nodeIndex: \(item.id)")
                                .preference(
                                    key: PositionKey.self,
                                    value: [item.id: proxy.frame(in: coordinateSpace)])
                        }
                        .frame(width: 200, height: 100)
                    }
                }
            }
            
        }
    }
}
