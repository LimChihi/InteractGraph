//
//  GraphView.swift
//  InteractGraph
//
//  Created by limchihi on 16/11/2021.
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

internal struct GraphView: View {
    
    private let viewGraph: AdjacencyListGraph<ViewElementGraph.Element>
    
    private let onTapNode: (ViewElementGraph.Element) -> ()
    
    internal init(viewGraph: AdjacencyListGraph<ViewElementGraph.Element>, onTapNode: @escaping (ViewElementGraph.Element) -> ()) {
        self.viewGraph = viewGraph
        self.onTapNode = onTapNode
    }
    
    public var body: some View {
        GraphNodeView(viewGraph: viewGraph, coordinateSpace: .named(coordinateSpaceName), rankGap: 50, levelGap: 50, onTapNode: onTapNode)
        .overlayPreferenceValue(ElementFramesKey.self) { preference in
            GeometryReader { reader in
                let frames = preference.mapValues { value in
                    reader[value]
                }
                GraphEdgesView(elementFrames: frames)
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
    
}

fileprivate let coordinateSpaceName = "com.limchihi.ZStack.Graph"

struct GraphView_Previews: PreviewProvider {
    
    static var data: AdjacencyListGraph<ViewElementGraph.Element> {
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
