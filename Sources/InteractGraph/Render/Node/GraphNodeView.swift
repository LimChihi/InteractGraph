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

    private let viewGraph: AdjacencyListGraph<ViewElementGraph.ViewElement>
    
    private let coordinateSpace: CoordinateSpace
    
    private let rankGap: CGFloat
    
    private let levelGap: CGFloat
    
    private let onTapNode: (ViewElementGraph.ViewElement) -> ()
    
    internal init(viewGraph: AdjacencyListGraph<ViewElementGraph.ViewElement>, coordinateSpace: CoordinateSpace, rankGap: CGFloat, levelGap: CGFloat, onTapNode: @escaping (ViewElementGraph.ViewElement) -> ()) {
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
                        GeometryReader { reader in
                            Group {
                                switch item.element {
                                case .node(let nodeIndex):
                                    EllipseLabelView(node: graph[nodeIndex])
                                        .background()
                                        .onTapGesture {
                                            onTapNode(item)
                                        }
                                case .edge:
                                    Spacer()
                                }
                            }
                            .preference(key: ElementFramesKey.self, value: [item.element: reader.frame(in: coordinateSpace)])
                        }
                        .frame(width: item.frame.width, height: item.frame.height)
                    }
                }
            }
        }
    }
}

internal struct ElementFramesKey: PreferenceKey {

    typealias Value = [ViewElementGraph.Element: CGRect]
    
    static let defaultValue: [ViewElementGraph.Element: CGRect] = [:]
    
    static func reduce(value: inout [ViewElementGraph.Element: CGRect], nextValue: () -> [ViewElementGraph.Element: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
    
}


extension Dictionary where Key == ViewElementGraph.Element, Value == CGRect {
    
    internal func edgeFrames(_ edge: EdgeIndex) -> [CGRect] {
        compactMap { key, value in
            guard case .edge(let caseEdge) = key else {
                return nil
            }
            guard caseEdge == edge else {
                return nil
            }
            
            return value
        }
        .sorted { $0.minY > $1.minY }
    }
}


struct GraphNodeView_Previews: PreviewProvider {
    
    static var data: AdjacencyListGraph<ViewElementGraph.ViewElement> {
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
