//
//  GraphNodeView.swift
//  InteractGraph
//
//  Created by lim on 22/11/2021.
//

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
