//
//  GraphNodeView.swift
//  InteractGraph
//
//  Created by limchihi on 22/11/2021.
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

internal struct GraphNodeView: View {
    
    @Environment(\.graph)
    private var graph: Graph

    private let viewGraph: AdjacencyListGraph<ViewElementGraph.Element>
    
    private let coordinateSpace: CoordinateSpace
    
    private let rankGap: CGFloat
    
    private let levelGap: CGFloat
    
    private let onTapNode: (ViewElementGraph.Element) -> ()
    
    internal init(viewGraph: AdjacencyListGraph<ViewElementGraph.Element>, coordinateSpace: CoordinateSpace, rankGap: CGFloat, levelGap: CGFloat, onTapNode: @escaping (ViewElementGraph.Element) -> ()) {
        self.viewGraph = viewGraph
        self.coordinateSpace = coordinateSpace
        self.rankGap = rankGap
        self.levelGap = levelGap
        self.onTapNode = onTapNode
    }
    
    var body: some View {
        LazyVStack(spacing: rankGap) {
            ForEach(viewGraph.storage) { rank in
                LazyHStack(spacing: levelGap) {
                    ForEach(rank) { item in
                        Group {
                            switch item {
                            case .node(let nodeIndex):
                                NodeView(node: graph[nodeIndex])
                                    .frame(minWidth: 120)
                                    .background()
                                    .onTapGesture {
                                        onTapNode(item)
                                    }
                            case .edge:
                                Spacer()
                                    .frame(width: 10)
                            }
                        }
                        .frame(minHeight: 80)
                        .anchorPreference(key: ElementFramesKey.self, value: .bounds) {
                            [item: $0]
                        }
                    }
                }
            }
        }
    }
}

internal struct ElementFramesKey: PreferenceKey {
    
    internal typealias Value = [ViewElementGraph.Element: Anchor<CGRect>]
    
    internal static let defaultValue: Value = [:]
    
    internal static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
    
}


struct GraphNodeView_Previews: PreviewProvider {
    
    static var data: AdjacencyListGraph<ViewElementGraph.Element> {
        let graph = test_data_graph
        let viewElementGraph = ViewElementGraph(graph)
        return viewElementGraph.storage
    }
    
    static var previews: some View {
        GraphNodeView(viewGraph: data, coordinateSpace: .local, rankGap: 50, levelGap: 50, onTapNode: { _ in })
            .environment(\._graph, test_data_graph)
            .frame(width: 600, height: 600)
    }
}
