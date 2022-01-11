//
//  Renderer.swift
//  InteractGraph
//
//  Created by limchihi on 8/1/2022.
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
   
import Clibgraphviz
import Foundation

internal func render(dot: String) async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
        render(dot: dot) { result in
            continuation.resume(with: result.map { String(data: $0, encoding: .utf8)! })
        }
    }
}

fileprivate func render(dot: String, handler: @escaping (Result<Data, Error>) -> ()) {
    queue.async {
        let result: Result<Data, Error> = Result { () throws -> Data in
            let context = gvContext()
            defer {
                gvFreeContext(context)
            }
            
            let graph = try dot.withCString { dot in
                try attempt {
                    agmemread(dot)
                }
            }
            
            try graphLayout.withCString { layout in
                try attempt {
                    gvLayout(context, graph, layout)
                }
            }
            defer {
                gvFreeLayout(context, graph)
            }
            
            var data: UnsafeMutablePointer<Int8>?
            var length: UInt32 = 8
            
            try graphFormat.withCString { format in
                try attempt {
                    gvRenderData(context, graph, format, &data, &length)
                }
            }
            defer {
                gvFreeRenderData(data)
            }
            guard let data = data else {
                fatalError()
            }

            return Data(bytes: UnsafeRawPointer(data), count: Int(length))
        }
        
        handler(result)
    }
}


fileprivate let graphLayout = "dot"

fileprivate let graphFormat = "json"

fileprivate let queue = DispatchQueue(label: "org.InteractGraph.GraphViz.rendering")
