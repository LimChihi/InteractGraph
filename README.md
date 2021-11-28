# InteractGraph


InteractGraph: A weak Graph tool.

<p align="center">
  <img height="300" src="ReadMeResources/Sample.png" />
</p>
**⚠️  The `InteractGraph` is currently undergoing rapid iteration and the public APIs are not guaranteed to be stable.**

***

## Feature

- [x] filter

### Node Attributes

- [x] label
- [x] borderColor
- [x] dashed border

## Usage

Prepared graph.

```swift
import InteractGraph

var graph: Graph {
  let graph = Graph() 
  
  let node0 = Node(id: 0x0, label: "0x0: TheBeginningOfEverything")
  ...
  let node42 = Node(id: 0x42, label: "0x42: TheAnswerToEverything")
  graph.addNodes([node0, ..., node42])
  
  let edge0 = Edge(from: node0, to: node42)
  ...
  let edge42 = Edge(from: node42, to: node0)
	graph.addEdges([edge0, ..., edge42])
 
  return graph
}
```

Then bring `InteractGraphView` to your view

```swift
import SwiftUI
import InteractGraph

struct ContentView: View {
	var graph: Graph { ... }
  var body: some View {
    InteractGraphView(graph: graph)
  }
}

```

## Requirements

- iOS 15.0+
- macOS 12.0+

## Future of InteractGraph

- [ ] Optimize graph layering algorithm. (It's longest-path now)
- [ ] More Node's and Edge's Attribute support.
- [ ] JSON Graph data import.
- [ ] Graph data dynamic record.
- [ ] Accessibility.

## Sponsors

GitHub sponsors is not supported my region yep.
