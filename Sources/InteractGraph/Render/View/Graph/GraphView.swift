//
//  GraphView.swift
//  InteractGraph
//
//  Created by lim on 16/11/2021.
//

import SwiftUI

internal struct GraphView: View {
    
    private let viewGraph: AdjacencyListGraph<ViewElementGraph.ViewElement>
    
    private let onTapNode: (ViewElementGraph.ViewElement) -> ()
    
    @State
    private var elementFrames: ElementFramesKey.Value = [:]
    
    internal init(viewGraph: AdjacencyListGraph<ViewElementGraph.ViewElement>, onTapNode: @escaping (ViewElementGraph.ViewElement) -> ()) {
        self.viewGraph = viewGraph
        self.onTapNode = onTapNode
    }
    
    public var body: some View {
        ZStack {
            GraphNodeView(viewGraph: viewGraph, coordinateSpace: .named(coordinateSpaceName), rankGap: 50, levelGap: 50, onTapNode: onTapNode)
            GraphEdgesView(elementFrames: elementFrames)
        }
        .onPreferenceChange(ElementFramesKey.self) { newValue in
            elementFrames = newValue
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
    
}

fileprivate let coordinateSpaceName = "com.limchihi.ZStack.Graph"

struct GraphView_Previews: PreviewProvider {
    
    static var data: AdjacencyListGraph<ViewElementGraph.ViewElement> {
        let graph = test_data_graph
        let viewElementGraph = ViewElementGraph(graph)
        return viewElementGraph.storage
    }
    
    static var previews: some View {
        GraphView(viewGraph: data, onTapNode: { _ in })
            .environment(\._graph, test_data_graph)
            .frame(width: 600, height: 600, alignment: .center)
    }
}
