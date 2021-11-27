//
//  InteractGraphView.swift
//  InteractGraph
//
//  Created by lim on 26/11/2021.
//

import SwiftUI

public struct InteractGraphView: View {
    
    private let rawGraph: Graph
    
    @State
    private var graph: ViewElementGraph
    
    public init(graph: Graph) {
        let layoutGraph = LayoutGraph(graph)
        
        self.rawGraph = graph
        self.graph = ViewElementGraph(layoutGraph)
    }
    
    public var body: some View {
        GraphView(graph: graph) { item in
            guard case let .node(node) = item.element else {
                return
            }
            
            let filterGraph = LayoutGraph(rawGraph, focusNode: node.id)
            withAnimation {
                self.graph = ViewElementGraph(filterGraph)
            }
        }
        .background()
        .onTapGesture {
            let layoutGraph = LayoutGraph(rawGraph)
            withAnimation {
                self.graph = ViewElementGraph(layoutGraph)
            }

        }
    }
}

//struct InteractGraphView_Previews: PreviewProvider {
//    static var previews: some View {
//        InteractGraphView()
//    }
//}
