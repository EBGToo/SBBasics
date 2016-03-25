//
//  Graph.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import SBCommons

// ===========================================================================
//
// MARK: Edge
//
//
class Edge<KE:Hashable, KN:Hashable> : Hashable {
  let key : KE
  let source : Node<KN, KE>
  let target : Node<KN, KE>
  var wgt : Double = 0.0
  
  init (key : KE, source: Node<KN, KE>, target: Node<KN, KE>) {
    self.key = key
    self.source = source
    self.target = target
    source.addEdge (self)

    // Edges are directed // undirected
    target.addEdge (self)
  }

  func hasSource (_ n : Node<KN, KE>) -> Bool {
    return n === source
  }

  func hasTarget (_ n: Node<KN, KE>) -> Bool {
    return n === target
  }
  
  func hasNode (_ node: Node<KN, KE>) -> Bool {
    return node === source || node === target
  }
  
  // isAdjacent -> Bool
  // adjacent -> Node<N>?
  
  // unlink
  
  func appNodes (_ apply : (Node<KN, KE>) -> Void) {
    apply(source); apply(target)
  }

  //
  // Weight
  //
  func edgeWgtEQ (_ that: Edge<KE,KN>) -> Bool {
    return self.wgt == that.wgt
  }
  
  func edgeWgtLT (_ that: Edge<KE,KN>) -> Bool {
    return self.wgt < that.wgt
  }
  
  //
  // Hash
  //
  public func hash(into hasher: inout Hasher) {
    hasher.combine (self.key)
  }
}

func == <KE:Hashable, KN:Hashable> (lhs:Edge<KE,KN>, rhs:Edge<KE,KN>) -> Bool {
  return lhs.key == rhs.key
}

// ===========================================================================
//
// MARK: Node
//
//
class Node<KN:Hashable, KE:Hashable> : Hashable {
  let key : KN
  var edges : Set<Edge<KE,KN>> = Set() // SortByWeight
  
  init (key: KN) {
    self.key = key
  }
  
  var isLeaf : Bool {
    return 0 == edges.count
  }
  
  func addEdge (_ edge : Edge<KE, KN>) {
    // ?? confirm edge.hasNode(self)
    edges.insert(edge)
  }
  
  func remEdge (_ edge : Edge<KE, KN>) {
    edges.remove(edge)
  }
  
  func hasEdge (_ edge : Edge<KE, KN>) -> Bool {
    return edges.contains (edge)
  }
  
  func appEdges (_ apply: (Edge<KE,KN>) -> Void) {
    edges.app (apply)
  }
  
  // appAdjacentEdge
  
  func appAdjacentNodes (_ apply: (Node<KN,KE>) -> Void) {
    edges.app { (edge:Edge<KE,KN>) in
      if edge.hasSource (self) {
        apply (edge.target)
      }
    }
  }
  
    public func hash(into hasher: inout Hasher) {
        hasher.combine (self.key)
    }

}

func ==<KN:Hashable, KE:Hashable> (lhs:Node<KN,KE>, rhs:Node<KN,KE>) -> Bool {
  return lhs.key == rhs.key
}

// ===========================================================================
//
// MARK: (Shortest) Path Weight
//
//
public class PathWeight<KN> : Comparable, CustomStringConvertible {
  public internal(set) var key : KN
  public internal(set) var wgt : Double = 0.0
  public internal(set) var lnk : KN?
  
  internal init (key: KN, wgt: Double) {
    self.key = key
    self.wgt = wgt
  }
  
  public var description : String {
    return "<PathWeight key: \(key), wgt: \(wgt)>"
  }
}

public func == <KN> (lhs:PathWeight<KN>, rhs:PathWeight<KN>) -> Bool {
  return lhs.wgt == rhs.wgt
}

public func < <KN> (lhs:PathWeight<KN>, rhs:PathWeight<KN>) -> Bool {
  return lhs.wgt > rhs.wgt
}

enum ShortestPathAlgorithm {
  case dijkstra
  case bellmanFord
  case any
}

// ===========================================================================
//
// MARK: Search Box
//
//

class SearchBox<Item:Hashable> : Box<Item>, Hashable { // : Hashable {
  
  var kids = [SearchBox<Item>]()
  
  var d : UInt = UInt.max
  var f : UInt = UInt.max
  
  init (item:Item, parent: SearchBox) {
    super.init(item:item)
    self.parent = parent
  }
  
  override init(item: Item) {
    super.init(item:item)
  }
  
  func kidAdd (_ s: SearchBox) {
    s.parent = self
    kids.append(s)
  }
  
  func kidApp (_ f: (SearchBox<Item>) -> Void) {
    kids.app(f)
  }
  
    public func hash(into hasher: inout Hasher) {
        hasher.combine (self.item)
    }

}

func ==<Item:Hashable> (lhs:SearchBox<Item>, rhs:SearchBox<Item>) -> Bool {
  return lhs.item == rhs.item
}


// ===========================================================================
//
// MARK: Graph
//

///
/// A Graph ...
///
public class Graph<KN:Hashable, KE:Hashable> {
  var nodes : [KN : Node<KN, KE>] = [:]
  var edges : [KE : Edge<KE, KN>] = [:]
  
  public init ( ) {}
  
  // MARK: Node

  public func hasNode (_ key:KN) -> Bool {
    return nil != nodes[key]
  }
  
  public func addNode (_ key:KN) {
    nodes[key] = Node<KN,KE>(key: key)
  }
  
  public func remNode (_ key:KN) {
    if let _ = nodes[key] {
      /*
      node.appEdges { (edge:Edge<KE,KN>) in
        self.edges.removeValueForKey(edge.key)
      }
      */
      nodes.removeValue(forKey: key)
    }
  }

  public var countOfNodes : Int {
    return nodes.count
  }
  
  public func appNodes (_ apply: (_ key:KN) -> Void) {
    for (_, node): (KN, Node<KN,KE>) in nodes {
      apply (node.key)
    }
  }
  
  internal func appNodesInternal (_ apply: (_ node:Node<KN,KE>) -> Void) {
    for (_, node): (KN, Node<KN,KE>) in nodes {
      apply (node)
    }
  }
  
  // MARK: Edge

  public func hasEdge (_ key:KE) -> Bool {
    return nil != edges[key]
  }
  
  // Deal with this... no node, no edge
  public func addEdge (_ key:KE, source:KN, target:KN, weight:Double = 0.0) {
    if let src = nodes[source], let tgt = nodes[target] {
      let edge = Edge(key: key, source: src, target: tgt)
      edge.wgt = weight
      edges[key] = edge
    }
  }
  
  // remEdgeIntenal (used by remNode ??)
  
  public func remEdge (_ key:KE) {
    if let edge = edges[key] {
      edge.source.remEdge(edge)
      edge.target.remEdge(edge)
      edges.removeValue(forKey: key)
    }
  }
  
  public var countOfEdges : Int {
    return edges.count
  }
  
  public func edgeSourceAndTarget (_ key:KE) -> (source:KN, target:KN)? {
    if let edge = edges[key] {
      return (edge.source.key, edge.target.key)
    }
    return nil
  }
  
  public func edgeWgt (_ key:KE) -> Double? {
    return edges[key]?.wgt;
  }
  
  public func appEdges (_ apply: (_ key:KE, _ source:KN, _ target:KN) -> Void) {
    for (_, edge): (KE, Edge<KE,KN>) in edges {
      apply (edge.key, edge.source.key, edge.target.key)
    }
  }

  internal func appEdgesInternal (_ apply: (_ edge:Edge<KE,KN>) -> Void) {
    for (_, edge): (KE, Edge<KE,KN>) in edges {
      apply (edge)
    }
  }
  
  internal var edgesSorted : [Edge<KE,KN>] {
    return Array(edges.values).sorted { (e1:Edge<KE, KN>, e2:Edge<KE, KN>) -> Bool in
      e1.edgeWgtLT(e2)
    }
  }

  // MARK: Walk
  
  ///
  /// Starting from each of the `roots`, visit all reachable nodes and apply `f` to each.
  ///
  /// - parameter roots: The nodes to begin walking from.
  /// - parameter f: The function to apply to each visited node
  ///
  public func walkPaths (_ roots: [KN], f: ((List<KN>) -> ())) {
    
    // Set of nodes that have been visited.
    var visited = Set<Node<KN,KE>>()
    
    // Returns TRUE if NODE needs to be visited (has not been visited in the
    // past); otherwise FALSE is returned.
    func visit (_ node:Node<KN,KE>) -> Bool {
      if visited.contains(node) { return false }
      else {
        visited.insert(node)
        return true
      }
    }

    for nd in roots {
      if let node = self.nodes[nd] {
        self.walkPathsFromNode (node,
          path: List<Node<KN, KE>>(),
          visit: visit,
          handle: f)
      }
    }
  }
  
  // typealias walkPathVisitor = (node:Node<KN,KE>, var path: List<Node<KN,KE>>) -> Void

  func walkPathsFromNode (_ node:Node<KN,KE>, path: List<Node<KN,KE>>,
    visit: (_ node:Node<KN,KE>) -> Bool,
    handle: (List<KN>) -> Void) {
      
      var path = path
      
      // Extend the path
      path = List (node, path)
      
      // Assume a leaf, unless we visit an adjacent node
      var leaf = true;
      node.appAdjacentNodes { (next: Node<KN, KE>) in
        if visit (next) {
          leaf = false
          self.walkPathsFromNode(next, path: path, visit: visit, handle: handle)
        }
      }
      
      if leaf { handle (path.reverse.map { $0.key }) }
  }
  
  
  // MARK: Breadth First Search
  
  ///
  /// Perform a 'Breadth First Search' staring at `key` and applying `f` when each node is 
  /// first visited.
  ///
  /// - parameter key: The node to start from.
  /// - parameter f: The function to apply to each visited node
  ///
  public func breadthFirstSearch (_ key: KN, f: @escaping ((_ key: KN) -> Void)) {
    breadthFirstSearchInternal (key,
      starter: { (node:Node<KN,KE>) in f (node.key) })
  }

  ///
  /// Perform a 'Breadth First Search' starting at `key`, apply `starter` and `finisher` when each
  /// node if visited for the first and last time respectively, and apply `rooter` to each root
  /// node.
  ///
  /// - parameter key: The node to start from.
  /// - parameter starter: The function to apply when first visited
  /// - parameter finisher: The function to apply when last visited
  /// - parameter rooter: The function to aply to each root.
  ///
  public func breadthFirstSearchDetailed (_ key: KN,
    starter:  @escaping ((_ key: KN) -> Void)  = { (key: KN) in return },
    finisher: @escaping ((_ key: KN) -> Void)  = { (key: KN) in return },
    rooter:   ((_ key: KN) -> Void)? = nil)
  {
    breadthFirstSearchInternal (key,
      starter:  { (node) in starter  (node.key) },
      finisher: { (node) in finisher (node.key) },
      rooter:   (nil == rooter ? nil : { (node) in rooter! (node.key) }))
  }

  internal func breadthFirstSearchInternal (_ key: KN,
    starter:  @escaping ((_ node: Node<KN,KE>) -> Void)  = { (node: Node<KN,KE>) in return },
    finisher: @escaping ((_ node: Node<KN,KE>) -> Void)  = { (node: Node<KN,KE>) in return },
    rooter:   ((_ node: Node<KN,KE>) -> Void)? = nil)
  {
    // Skip out
    if nil == nodes[key] { return }
    
    typealias Box = SearchBox<Node<KN,KE>>
    
    var time : UInt = 0
    
    // Map from Node to SearcherBox - holds intermediate data.
    var boxMap : [Node<KN,KE> : Box] = [:]
    
    func visit (_ n: Node<KN,KE>, c: BoxColor, d: UInt, ps : Box?) {
      let s = boxMap[n]!
      s.color = c
      s.d     = d
      ps?.kidAdd(s)
      starter (n)
    }
    
    // Give every Node a SearchBox to hold walk state
    self.appNodesInternal { (node: Node<KN,KE>) in boxMap[node] = SearchBox(item: node) }
    
    var queue = Queue<Node<KN,KE>>()
    
    func search (_ n: Node<KN,KE>) {
      let ns = boxMap[n]!
      n.appAdjacentNodes { (x: Node<KN, KE>) in
        let xs = boxMap[x]!
        if .white == xs.color {
          time += 1
          visit (x, c: .gray, d: time, ps: ns)
          queue.enqueue (x)
        }
      }
      
      _ = queue.dequeue().map (search)

      ns.color = .black
      finisher(n)
    }
    
    time += 1
    visit (nodes[key]!, c: .gray, d: time, ps: nil)
    search (nodes[key]!)
    
    // If provided, apply ROOTER to each root node.  Create a Set<Root> to
    // ensure that roots are only visited once.  Application order is undefined.
    if nil != rooter {
      var roots : Set<Node<KN,KE>> = Set()
      appNodesInternal { (node:Node<KN,KE>) in
        roots.insert(boxMap[node]!.founder.item)
        return
      }
      roots.app(rooter!)
    }
  }
  
  // MARK: Depth First Search
  
  ///
  /// Perform a 'Depth First Search' staring at `key` and applying `f` when each node is
  /// first visited.
  ///
  /// - parameter key: The node to start from.
  /// - parameter f: The function to apply to each visited node
  ///
  func depthFirstSearch (_ key: KN, f: @escaping ((_ key: KN) -> Void)) {
    if hasNode(key) {
      depthFirstSearchInternal (key,
        starter: { (node:Node<KN,KE>) in f (node.key) })
    }
  }

  ///
  /// Perform a 'Depth First Search' starting at `key`, apply `starter` and `finisher` when each
  /// node if visited for the first and last time respectively, and apply `rooter` to each root
  /// node.
  ///
  /// - parameter key: The node to start from.
  /// - parameter starter: The function to apply when first visited
  /// - parameter finisher: The function to apply when last visited
  /// - parameter rooter: The function to aply to each root.
  ///
  func depthFirstSearchDetailed (_ key: KN,
      starter:  @escaping ((_ key: KN) -> Void)  = { (key: KN) in return },
      finisher: @escaping ((_ key: KN) -> Void)  = { (key: KN) in return },
      rooter:   ((_ key: KN) -> Void)? = nil)
  {
    depthFirstSearchInternal (key,
      starter:  { (node) in starter  (node.key) },
      finisher: { (node) in finisher (node.key) },
      rooter:   (nil == rooter ? nil : { (node) in rooter! (node.key) }))
  }

  ///
  /// Perform a 'Depth First Search' starting at an arbitary node and proceeding the search from
  /// other arbitary nodes until all nodes have been visited.  Apply `f` when each node is first
  /// encountered.
  ///
  /// - parameter f: The function to apply to each visited node.
  ///
  func depthFirstSearchAll (_ f: @escaping ((_ key: KN) -> Void)) {
    depthFirstSearchInternal (nil,
      starter: { (node:Node<KN,KE>) in f (node.key) })
  }
  
  ///
  internal func depthFirstSearchInternal (_ key: KN?,
    starter:  @escaping ((_ node: Node<KN,KE>) -> Void)  = { (node: Node<KN,KE>) in return },
    finisher: @escaping ((_ node: Node<KN,KE>) -> Void)  = { (node: Node<KN,KE>) in return },
    rooter:   ((_ node: Node<KN,KE>) -> Void)? = nil)
  {
    typealias Box = SearchBox<Node<KN,KE>>
    
    var time : UInt = 0
    //var isDirected = true
    
    // Map from Node to SearcherBox - holds intermediate data.
    var boxMap : [Node<KN,KE> : Box] = [:]
    
    // Visit A Node - tortured recursion (from search())
    //
    // We visit by looking up the node's box (sure to exist) and giving the
    // box the 'color' and 'depth' provided.  Additionally, if the parent
    // box exists we add node as a child.  Finally, we call the provided starter
    // function.
    func visit (_ n: Node<KN,KE>, c: BoxColor, d: UInt, ps : Box?) {
      let s = boxMap[n]!
      s.color = c
      s.d     = d
      ps?.kidAdd (s)
      starter (n)
    }
    
    // Search a Node - tortured recursion
    //
    // We search with node only if the node is colored .White (never visited).
    // We'll visit the node and then search each of the adjacent nodes.  Once
    // that depth-first search completes, we'll make the node and then call
    // the finisher function.
    
    func search (_ n: Node<KN,KE>, pn: Node<KN,KE>?) {
      let ns = boxMap[n]!
      if .white == ns.color {
        time += 1
        visit (n, c: .gray, d: time, ps: (nil == pn ? nil : boxMap[pn!]))
        n.appAdjacentNodes { (c) in search (c, pn:n) }
        
        ns.color = .black
        time += 1; ns.f = time
        finisher (n)
      }
    }
    
    // Give every Node a SearchBox to hold walk state
    self.appNodesInternal { (node: Node<KN,KE>) in boxMap[node] = SearchBox(item: node) }
    
    // Search from KEY if provided; othewise search from all
    if nil != key { search (self.nodes[key!]!, pn: nil) }
    else { appNodesInternal{ (n) in search (n, pn:nil) }}
    
    // If provided, apply ROOTER to each root node.  Create a Set<Root> to
    // ensure that roots are only visited once.  Application order is undefined.
    if nil != rooter {
      var roots : Set<Node<KN,KE>> = Set()
      appNodesInternal { (node:Node<KN,KE>) in
        roots.insert(boxMap[node]!.founder.item)
        return
      }
      roots.app(rooter!)
    }
  }
  
  // MARK: Groups of Nodes
  
  ///
  /// Sort the nodes topologically (that is, based on their edge relationships). Return a list of 
  /// sorted nodes.
  ///
  public var topologicalSort : List<KN> {
    // assert (graph is directed?)
    
    var keys : List<KN> = List<KN>()
    
    depthFirstSearchInternal (nil,
      finisher: { (node:Node<KN,KE> ) in keys = List<KN> (node.key, keys) })

    return keys
  }
  
  ///
  /// Return the set of ancestor nodes for each connected component
  ///
  /// - returns: The set of nodes when each node is in a connected component and where all nodes
  ///   in the connected component can be reached from the node.
  ///
  public var connectedComponents : Set<KN> {
    
    // For each node we'll associate a FamilyLink.  We'll then examine each
    // edge and create a child relationship between source and sink.  The
    // connected-components will be the set of ancestors.
    
    // This should be a Forest...
    
    var nodeToCC : [KN:BoxedTree<Node<KN,KE>>] = [:]
    
    appNodesInternal { (node:Node<KN,KE>) -> Void in
      nodeToCC[node.key] = BoxedTree<Node<KN,KE>>(item: node)
    }
    
    appEdgesInternal { (edge:Edge<KE,KN>) -> Void in
      let srcBox = nodeToCC[edge.source.key]!
      let tgtBox = nodeToCC[edge.target.key]!
      
      srcBox.addKid(tgtBox)
    }
    
    var cc = Set<KN>()
    
    appNodesInternal { (node:Node<KN,KE>) in
      cc.insert(nodeToCC[node.key]!.founder.item.key)
      return
    }
    
    return cc;
  }
  
  ///
  ///
  ///
  public var minimalSpanningTree : Set<KE> {
    var nodeToBox = Dictionary<KN, BoxedTree<Node<KN,KE>>>()
    
    appNodesInternal { (node:Node<KN,KE>) -> Void in
      nodeToBox[node.key] = BoxedTree(item: node)
    }
    
    var mst = Set<KE>()
    
    edgesSorted.app { (edge:Edge<KE,KN>) in
      let srcBox = nodeToBox[edge.source.key]!
      let tgtBox = nodeToBox[edge.target.key]!
      
      if srcBox !== tgtBox {
        mst.insert(edge.key)
        srcBox.addKid (tgtBox)
      }
    }
    
    return mst
  }

  // MARK: Shortest Path
  
  ///
  /// The return type for 'Shortest Path' is a Dictionary mapping every visited node to its
  /// PathWeight
 ///
  public typealias ShortestPathReturn = [KN : PathWeight<KN>] // Table: Node -> est+par
  
  ///
  /// Find the shortest path staring with `key`.  Use any shortest path algorithm
  ///
  /// - parameter key: The node to start from
  ///
  public func shortestPath (_ key: KN) -> ShortestPathReturn {
    return shortestPathInternal(key, algorithm: .any)
  }
  
  ///
  /// Find the shortest path staring with `key` using the Dijkstra shortest path algorithm.
  ///
  /// - parameter key: The node to start from
  ///
  public func shortestPathDijkstra (_ key: KN) -> ShortestPathReturn {
    return shortestPathInternal(key, algorithm: .dijkstra)
  }
  
  ///
  /// Find the shortest path staring with `key` using the BellmanFord shortest path algorithm.
  ///
  /// - parameter key: The node to start from
  ///
  public func shortestPathBellmanFord (_ key: KN) -> ShortestPathReturn {
    return shortestPathInternal(key, algorithm: .bellmanFord)
  }
  
  ///
  internal func shortestPathInternal (_ key: KN, algorithm: ShortestPathAlgorithm) -> ShortestPathReturn {
    if nil == nodes[key] { return [:] }
    
    var algorithm = algorithm
    
    // We are computing the shortest path from KEY to every NODE.  We'll capture
    // the paths as a dictionary mapping from node's key to a) the path weight
    // from KEY (or parent) and b) the parent
    
    var paths : [KN : PathWeight<KN>] = [:]
    
    func relax (_ e:Edge<KE,KN>) -> Bool {
      let pathSource = paths[e.source.key]!
      let pathTarget = paths[e.target.key]!
      
      let dist = pathSource.wgt + e.wgt
      
      if pathTarget.wgt > dist {
        pathTarget.wgt = dist
        pathTarget.lnk = e.source.key
        return true
      }
      else { return false }
    }
    
    // Assume .Dijkstra as it is more general than .BellmanFord
    
    var conformingAlgorithm : ShortestPathAlgorithm = .dijkstra
    
    // We are finding the shortest path - so, we'll determine the absolute
    // longest path and then minimize from that.  The weight limit must be less
    // than the sum of the absolute value of all the edge weights.
    
    var weightLimit = 0.0
    
    appEdgesInternal { (edge) -> Void in
      weightLimit += abs (edge.wgt)
      if edge.wgt < 0.0 {
        conformingAlgorithm = .bellmanFord
      }
    }
    
    algorithm = conformingAlgorithm
    
    // Initialize all the paths with the weightLimit; we'll minimize off that.
    
    appNodesInternal { (node) in
      paths[node.key] = PathWeight<KN> (key: node.key, wgt: weightLimit)
    }
    
    // Start at source,
    let source = nodes[key]!
    
    paths[source.key]!.wgt = 0.0
    
    switch algorithm {
    case .any:
      fallthrough
    case .bellmanFord:
      // We'll relax all edges countOfNodes times (M*N)
      for _ in 0..<countOfNodes {
        appEdgesInternal{ (e) in _ = relax (e); return }
      }
      
      /*
      var count : Int = countOfNodes
      while --count >= 0 {
        appEdgesInternal{ (e) in relax (e); return }
      }
      */
      
    case .dijkstra:
      var heap = Heap<PathWeight<KN>>()
      
      appNodesInternal { (node) in
        heap.insert(paths[node.key]!)
      }
      
      print (heap);
      while let path = heap.extract() {
        print (path)
        nodes[path.key]!.appEdges { (e) in
          if relax (e) {
            let pathTarget = paths[e.target.key]!
            // Owing to relax() returning true, the pathTarget has
            // decreased - we've found a shorter path.  We need to re-heap
            // pathTarget
            heap.reheap (pathTarget)
          }
        }
      }
    }
    
    // path exists
    var pathExists = true
    
    appEdgesInternal { (e) in
      pathExists = pathExists && paths[e.target.key]!.wgt >= paths[e.source.key]!.wgt + e.wgt
    }
    
    return paths
  }
}
