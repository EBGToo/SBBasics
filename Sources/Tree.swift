//
//  Tree.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import SBCommons

// MARK: Tree Type

///
/// A TreeType ...
///
public protocol TreeType { // BagType
  associatedtype Item
  associatedtype Visitor = (Item) -> Void

  /// The `item`
  var item : Item { get }

  /// The `kids`
  var kids : [Self] { get }
  
  /// `true` if no `kids`; otherwise `false` - aka `isLeaf`
  var isKidless : Bool { get }
  
  /// The number of kids
  var degree : Int { get }
  
  /// The number of descendents (includes self)
  var count : Int { get }

  /// The longest count of descendents along any path.  A leaf (no kids) has a height of zero
  var height : Int { get }
  
  ///
  /// The number of parents to `item` if found based on `pred`.  A kidLess tree has a depth
  /// of zero
  ///
  /// - parameters:
  ///    - item: The item 
  ///    - pred: The test for item
  ///
  func depth (_ item: Item, pred: (Item, Item) -> Bool) -> Int?
  
  /// The parent of item if found based on `pred`
  func parent (_ item: Item, pred: (Item, Item) -> Bool) -> Self?
  
  /// Check if `item`, based on `pred`, exists
  func contains (_ item: Item, pred: (Item, Item) -> Bool) -> Bool

  func walkByDepth (preOrder: Visitor?, inOrder: Visitor?, postOrder: Visitor?)
  
  func walkByBreadth (preOrder: Visitor?, postOrder: Visitor?)
  
  /// All items
  var array : Array<Item> { get }
}

extension TreeType {
  func walkByDepth (_ inOrder: Visitor) {
    walkByDepth(preOrder: nil, inOrder: inOrder, postOrder: nil)
  }
  
  func walkByBreadth(_ preOrder: Visitor) {
    walkByBreadth(preOrder: preOrder, postOrder: nil)
  }

  // descendents
  // kidsApp
  // kidsMap
  // kidsReduce
  // func parent<I:Equatable where Item == I> (item: I)
}

extension TreeType where Item:Equatable {
  func contains (_ item:Item) -> Bool {
    return contains (item, pred:==)
  }
}

// MARK: Tree

///
/// A Tree is a TreeType ...
///
public struct Tree<T> : TreeType {
  public typealias Item = T
  public typealias Visitor = (Item) -> Void
  
  public let item : Item
  public var kids : [Tree<Item>]
  
  public init (item: Item) {
    self.init (item: item, kids: [])
  }
  
  public init (item: Item, kids: [Tree<Item>]) {
    self.item = item
    self.kids = kids
  }
  
  public init (item: Item, items: [Item]) {
    self.item = item
    self.kids = items.map { Tree<Item>(item: $0) }
  }
  
  // MARK: TreeType
  
  public var isKidless : Bool {
    return kids.isEmpty
  }

  public var degree : Int {
    return kids.count
  }
  
  public var count : Int {
    return kids.map { $0.count }.reduce(1, +)
  }
  
  public var height : Int {
    return kids.isEmpty ? 0 : (1 + kids.map { $0.height }.reduce (Int.min, max))
  }
  
  public func depth (_ item: Item, pred: (Item, Item) -> Bool) -> Int? {
    if pred (self.item, item) { return 0 }
    
    let result = kids.compactMap { $0.depth (item, pred: pred) }
      .reduce (Int.max, min)
  
    return result == Int.max ? nil : 1 + result
  }
  
  /// The parent of item if found based on `pred`
  public func parent (_ item: Item, pred: (Item, Item) -> Bool) -> Tree? {
    if kids.any ({ pred ($0.item, item) }) { return self }
    else {
      return kids.compactMap { $0.parent (item, pred: pred) }.first
    }
  }
  
  public func contains (_ item: Item, pred: (Item, Item) -> Bool) -> Bool {
    return pred (self.item, item) || kids.any { $0.contains (item, pred: pred) }
  }

  ///
  public func walkByBreadth(preOrder: Visitor?, postOrder: Visitor?) {
    var queue = Queue<Tree<Item>>()

    func walk (_ tree:Tree<Item>) {
      preOrder? (tree.item)

      tree.kids.forEach {
        queue.enqueue($0)
      }

      _ = queue.dequeue().map(walk)

      postOrder?(tree.item)
    }

    walk(self)
  }
  
  ///
  public func walkByDepth (preOrder: Visitor?, inOrder: Visitor?, postOrder: Visitor?) {
    func rwalk (_ t: Tree<Item>) {
      t.walkByDepth (preOrder: preOrder, inOrder: inOrder, postOrder: postOrder)
    }

    preOrder?(item)

    var needVisit = false
    kids.forEach {
      if needVisit { inOrder? (self.item) }
      rwalk ($0)
      needVisit = true
    }
    
    postOrder?(item)
  }
  
  public var array : Array<Item> {
    //return kids.map { $0.items }.reduce([item]) { $0.appendContentsOf($1) }

    var result = [item]
    kids.map { $0.array }.forEach { result.append(contentsOf: $0) }
    return result
  }
}

// ===============================================================================================

// MARK: Binary Tree Type

///
/// A BinaryTreeType is a TreeType ...
///
public protocol BinaryTreeType : TreeType where Item : Comparable { //OrderedBagType
  
  /// The `left` subtree otherwise `nil`
  var left :  Self? { get }
  
  /// The `right` subtree, otherwise `nil`
  var right : Self? { get }
  
  /// Check if `item` is contained
  func contains (_ item: Item) -> Bool
  
  /// Depth (number of parents) to `item` (if it exists), otherwise nil
  func depth (_ item: Item) -> Int?
 
  // Restore: Self -> BinaryTree<Item>
  
  /// The parent of `item` (if it exists), otherwise nil
  func parent (_ item: Item) -> Self?
 
  /// The subtree (kidless, leaf) to the left
  var minimum : Self { get }
  
  /// The subtree (kidless, leaf) to the right
  var maximum : Self { get }

  /// The successor to `item` (if it exists), otherwise nil
  func successor (_ item: Item) -> Self?
  
  /// The predecessor to `item` (if it exists), otherwise nil
  func predecessor (_ item: Item) -> Self?
}

// MARK: Binary Tree

/// A `Color` is used to balance a binary tree: Red and Black
public enum Color { case r, b }

/// A `Order` defines a sub-search order; under .Breadth or .Depth
public enum Order { case preOrder, inOrder, postOrder }

///
/// A BinaryTree is an ordered set of Items

public enum BinaryTree<Item: Comparable> : BinaryTreeType {
  
  // Resursive Base - this is not exposed in a public interface (except this type itself)
  case empty
  
  // Recursive Tree - Note: a `leaf` is .Node (_, .Empty, _, .Empty)
  indirect case node(Color, BinaryTree<Item>, Item, BinaryTree<Item>)
  
  public typealias Visitor = (Item) -> Void
  
  private init () {
    self = .empty
  }
  
  private init(item: Item,
    color: Color = .b,
    left : BinaryTree<Item> = .empty,
    right: BinaryTree<Item> = .empty)
  {
    self = .node(color, left, item, right)
  }
  
  /// Initialize an instance as a `Leaf` with `item`
  public init (_ item: Item) {
    self.init (item: item)
  }

  /// Initialize an instance with `items`
  init (items: Array<Item>) {
    // By doing this, for a random array of N ~= 1000, speed up by x20
    let items = items.sorted()

    func recolor (_ color: Color) -> Color {
      switch color {
      case .r: return .b
      case .b: return .r
      }
    }
    
    func split (_ color: Color, _ items: ArraySlice<Item>) -> BinaryTree<Item> {
      let xolor = recolor (color)

      switch items.count {
      case 0: return .empty
      case 1:
        let item = items[items.startIndex]

        return .node(color, .empty, item, .empty)

      case 2:
        let litem = items[items.startIndex]
        let hitem = items[items.startIndex + 1]

        return .node(color, .empty, litem, .node(xolor, .empty, hitem, .empty))
        
      case 3:
        let litem = items[items.startIndex]
        let mitem = items[items.startIndex + 1]
        let hitem = items[items.startIndex + 2]

        return .node(color, .node(xolor, .empty, litem, .empty), mitem, .node(xolor, .empty, hitem, .empty))

      default:
        let ldex = items.startIndex
        let edex = items.endIndex
        let mdex = (edex + ldex) / 2

        let ltree = split (xolor, items[ldex..<mdex])
        let rtree = split (xolor, items[(mdex + 1)..<edex])

        return .node(color, ltree, items[mdex], rtree)
      }
    }
    
    self = split (.b, items[0..<items.count])
  }
  
  
  private func unexpectedEmpty () -> Never  {
    preconditionFailure("BinaryTree at .Empty unexpectedly.")
  }
  
  /// The `item`
  public var item : Item {
    switch self {
    case .empty: unexpectedEmpty()
    case let .node (_, _, item, _): return item
    }
  }
  
  /// The `left` subtree otherwise `nil`
  public var left : BinaryTree<Item>? {
    switch self {
    case .node (_, .empty, _, _): return nil
    case .node (_, let l , _, _): return l
    case .empty: unexpectedEmpty()
    }
  }
  
  /// The `right` subtree, otherwise `nil`
  public var right : BinaryTree<Item>? {
    switch self {
    case .node (_, _, _, .empty): return nil
    case .node (_, _, _, let r ): return r
    case .empty: unexpectedEmpty()
    }
  }
  
  /// The `kids` - composed of `left` and `right` nodes, that exist.
  public var kids : Array<BinaryTree<Item>> {
    switch self {
    case .node(_, .empty, _, .empty): return []
    case let .node (_, .empty, _, r): return [r]
    case let .node (_, l, _, .empty): return [l]
    case let .node (_, l, _, r): return [l, r]
    case .empty: unexpectedEmpty()
    }
  }

  /// `true` if no `kids`; otherwise `false` - aka `isLeaf`
  public var isKidless : Bool {
    switch self {
    case .empty: unexpectedEmpty()
    case .node (_, .empty, _, .empty): return true
    default: return false
    }
  }
  
  /// The number of kids
  public var degree : Int {
    switch self {
    case .empty: unexpectedEmpty()
    case .node (_, .empty, _, .empty): return 0
    case .node (_, .node,  _, .node ): return 2
    default: return 1
    }
  }
  
  /// The number of descendents (includes self)
  public var count : Int {
    switch self {
    case .empty: return 0
    case let .node (_, l, _, r):
      return 1 + l.count + r.count
    }
  }
  
  /// The longest count of descendents along any path.  A leaf (no kids) has a height of zero
  public var height : Int {
    switch self {
    case .empty: return -1
    case let .node (_, l, _, r):
      return 1 + max (l.height, r.height)
    }
  }
  
  ///
  /// The number of parents to `item` if found based on `pred`.  A kidLess tree has a depth
  /// of zero
  ///
  /// - parameters:
  ///    - item: The item
  ///    - pred: The test for item
  ///
  public func depth(_ item: Item, pred: (Item, Item) -> Bool) -> Int? {
    switch self {
    case let .node (_, .node(_, _, that, _), _, _)  where pred (that, item): return 1
    case let .node (_, _, _, .node (_, _, that, _)) where pred (that, item): return 1
    case let .node (_, l, that, r):
      // Caution on `pred` implies `==` but isn't `==`
      if item < that { return l.depth (item, pred: pred).map { 1 + $0 } }
      if item > that { return r.depth (item, pred: pred).map { 1 + $0 } }
      return 0
    case .empty: unexpectedEmpty()
    }
  }
  
  /// The parent of item if found based on `pred`
  public func parent (_ item: Item, pred: (Item, Item) -> Bool) -> BinaryTree<Item>? {
    switch self {
    case let .node (_, _, this, _) where pred (this, item): return nil
    case let .node (_, .node(_, _, that, _), _, _)  where pred (that, item): return self
    case let .node (_, _, _, .node (_, _, that, _)) where pred (that, item): return self
    case let .node (_, l, _, r):
      return l.parent (item) ?? r.parent (item)
    case .empty: unexpectedEmpty()
    }
  }

  /// Check if `item`, based on `pred`, exists
  public func contains(_ item: Item, pred: (Item, Item) -> Bool) -> Bool {
    switch self {
    case .empty: return false
    case let .node (_, l, that, r):
      return pred (that, item)
        || l.contains (item, pred: pred)
        || r.contains (item, pred: pred)
    }
  }

  public func walkByBreadth(preOrder: Visitor?, postOrder: Visitor?) {
    var queue = Queue<BinaryTree<Item>>()
    
    func walk (_ tree:BinaryTree<Item>) {
      preOrder? (tree.item)
      
      tree.kids.forEach {
        queue.enqueue($0)
      }
      
      _ = queue.dequeue().map(walk)
      
      postOrder?(tree.item)
    }
    
    walk(self)
  }
  
  ///
  public func walkByDepth (preOrder: Visitor?, inOrder: Visitor?, postOrder: Visitor?) {
    func rwalk (_ t: BinaryTree<Item>) {
      t.walkByDepth (preOrder: preOrder, inOrder: inOrder, postOrder: postOrder)
    }

    switch self {
    case .empty: return
    case let .node (_, l, item, r):
      preOrder?(item)
      rwalk(l)
      inOrder? (item)
      rwalk(r)
      postOrder? (item)
    }
  }

  /// All items
  public var array : [Item] {
    var result = [item]
    if let l = left  { result.append(contentsOf: l.array) }
    if let r = right { result.append(contentsOf: r.array) }
    return result
  }
  
  //
  // MARK: Binary Tree Type Implementation
  //
  
  /// Check if `item` is contained
  public func contains(_ item: Item) -> Bool {
    return nil != lookup(item)
  }
  
  /// Depth (number of parents) to `item` (if it exists), otherwise nil
  public func depth (_ item: Item) -> Int? {
    switch self {
    case .empty: return nil
    case let .node(_, l, that, r):
      if item < that { return l.depth (item).map { 1 + $0 } }
      if item > that { return r.depth (item).map { 1 + $0 } }
      return 0
    }
  }
  
  /// The parent of `item` (if it exists), otherwise nil
  public func parent (_ item: Item) -> BinaryTree<Item>? {
    switch self {
    case .empty: return nil
    case let .node (_, .node(_, _, that, _), _, _)  where that == item: return self
    case let .node (_, _, _, .node (_, _, that, _)) where that == item: return self
    case let .node (_, l, that, r):
      if item < that { return l.parent (item) }
      if item > that { return r.parent (item) }
      return nil
    }
  }
  
  /// The subtree (kidless, leaf) to the left
  public var minimum : BinaryTree<Item> {
    switch self {
    case .node (_, .empty, _, _): return self
    case .node (_, let l,  _, _): return l.minimum
    case .empty: unexpectedEmpty()
    }
  }
  
  /// The subtree (kidless, leaf) to the right
  public var maximum : BinaryTree<Item> {
    switch self {
    case .node (_, _, _, .empty): return self
    case .node (_, _, _, let r ): return r.maximum
    case .empty: unexpectedEmpty()
    }
  }

  func lookup (_ item: Item) -> BinaryTree<Item>? {
    switch self {
    case .empty: return nil
    case let .node(_, l, that, r):
      if item < that { return l.lookup (item) }
      if item > that { return r.lookup (item) }
      return self
    }
  }
  
  private typealias Box = BinaryTree<Item>
  
  private func lookup (_ item: Item, path: List<Box>, done: (_ path: List<Box>) -> Box?) -> Box? {
    switch self {
    case let .node (_, l, that, r):
      if item < that { return l.lookup (item, path: List<Box>(self, path), done: done) }
      if item > that { return r.lookup (item, path: List<Box>(self, path), done: done) }
      return done (List<Box>(self, path))
    case .empty: return done (List<Box>.none)
    }
  }

  private func upRight (_ path: List<Box>) -> Box? {
    guard let parent = path.car else { return nil }
    if parent.right?.item == item { return parent }
    else { return parent.upRight (path.cdr!) }
  }

  private func upLeft (_ path: List<Box>) -> Box? {
    guard let parent = path.car else { return nil }
    if parent.left?.item == item { return parent }
    else { return parent.upLeft (path.cdr!) }
  }
  
  public func predecessor (_ item: Item) -> BinaryTree<Item>? {
    return lookup (item, path: .none) { (path:List<Box>) -> Box? in
      guard case let .cons(box, rest) = path else { return nil } // Item not found
      return box.left?.maximum ?? box.upRight(rest)
    }
  }
  
  public func successor (_ item: Item) -> BinaryTree<Item>? {
    return lookup (item, path: .none) { (path:List<Box>) -> Box? in
      guard case let .cons(box, rest) = path else { return nil } // Item not found
      return box.right?.minimum ?? box.upLeft(rest)
    }
  }
    
  // MARK: Insert
  
  public func insertNew (_ item: Item) -> BinaryTree<Item> {
    func ins (_ this: BinaryTree<Item>, _ item: Item) -> BinaryTree<Item> {
      switch this {
      case .empty: return BinaryTree (item: item, color: .r)
      case let .node (color, left, that, right):
        if item < that { return BinaryTree (item: that, color: color, left: ins(left, item), right: right).balance() }
        if item > that { return BinaryTree (item: that, color: color, left: left, right: ins(right, item)).balance() }
        return self
      }
    }
    
    switch ins (self, item) {
    case .empty: fatalError ("impossible")
    case let .node (_, left, item, right):
      return .node(.b, left, item, right)
    }
  }
  
  public mutating func insert (_ item: Item) {
    self = insertNew (item)
  }
  
  private func balance() -> BinaryTree<Item> {
    switch self {
    case let .node(.b, .node(.r, .node(.r, a, x, b), y, c), z, d):
      return .node(.r, .node(.b,a,x,b), y, .node(.b,c,z,d))
      
    case let .node(.b, .node(.r, a, x, .node(.r, b, y, c)), z, d):
      return .node(.r, .node(.b,a,x,b), y, .node(.b,c,z,d))
      
    case let .node(.b, a, x, .node(.r, .node(.r, b, y, c), z, d)):
      return .node(.r, .node(.b,a,x,b), y, .node(.b,c,z,d))
      
    case let .node(.b, a, x, .node(.r, b, y, .node(.r, c, z, d))):
      return .node(.r, .node(.b,a,x,b), y, .node(.b,c,z,d))
      
    default:
      return self
    }
  }
  
  // MARK: Delete

  public func deleteNew (_ item: Item) -> BinaryTree<Item> {
    switch self {
    case .empty: return .empty
      
      // Right That Leaf
    case let .node (pc, pl, pi, .node (_, .empty, that, .empty)) where that == item:
      return .node (pc, pl, pi, .empty)

      // Left That Leaf
    case let .node (pc, .node (_, .empty, that, .empty), pi, pr) where that == item:
      return .node (pc, .empty, pi, pr)

      // Right That w/ Left Only
    case let .node (pc, pl, pi, .node (_, tl, that, .empty)) where that == item:
      return .node (pc, pl, pi, tl)
      
      // Right That w/ Right Only
    case let .node (pc, pl, pi, .node (_, .empty, that, tr)) where that == item:
      return .node (pc, pl, pi, tr)

      // Left That w/ Left Only
    case let .node (pc, .node (_, tl, that, .empty), pi, pr) where that == item:
      return .node (pc, tl, pi, pr)

      // Left That w/ Right Only
    case let .node (pc, .node (_, .empty, that, tr), pi, pr) where that == item:
      return .node (pc, tr, pi, pr)

      // Left That w/ Left and Right
    case let .node (pc, pl, pi, .node (tc, tl, that, tr)) where that == item:
      let succ = tr.minimum.item
      return .node (pc, pl, pi, .node (tc, tl, succ, tr.deleteNew(succ))) // rebalance if tr.minimum .B

      // Right That w/ Left and Right
    case let .node (pc, .node (tc, tl, that, tr), pi, pr) where that == item:
      let succ = tr.minimum.item
      return .node (pc, .node (tc, tl, succ, tr.deleteNew(succ)), pi, pr) // rebalance if tr.minimum .B

      // Self That w/ Left Only
    case let .node (_, l, that, .empty) where that == item:
      return l

      // Self That w/ Left and Right
    case let .node (c, l, that, r):
      if item < that { return BinaryTree (item: that, color: c, left: l.deleteNew(item), right: r) }
      if item > that { return BinaryTree (item: that, color: c, left: l, right: r.deleteNew(item)) }

      let succ = r.minimum.item // r exists
      return .node (c, l, succ, r.deleteNew (succ))
    }
  }
  
  public mutating func delete (_ item: Item) {
    self = deleteNew (item)
  }
}

extension BinaryTree : ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Item...) {
    self.init (items: elements)
  }
}


/*

//
// MARK: Forest
//
public struct Forest <Value> {
  
  var roots : [TreeNode<Value>] = []
  
  //
  // MARK: Forest Private 
  //
  func contains (node: TreeNode<Value>) -> Bool {
    return roots.contains (node.founder as! TreeNode<Value>)
  }
  
  //! Insert NODE as a ROOT in SELF.
  mutating func insert (node: TreeNode<Value>) -> TreeNode<Value>  {
    roots.append (node)
    return node
  }
  
  mutating func insert (node: TreeNode<Value>, parent: TreeNode<Value>) -> TreeNode<Value>? {
    if !contains(node) && contains (parent) {
      parent.addKid (node)
      return node
    }
    return nil
  }
  
  mutating func remove (node: TreeNode<Value>) -> Tree<Value>? {
    if !contains(node) { return nil }
    else if let index = roots.indexOf (node) {
      roots.removeAtIndex(index)
      return Tree<Value> (root: node)
    }
    else {
      (node.parent as! TreeNode<Value>).remKid (node)
      return Tree<Value>(root: node)
    }
  }

  //
  // MARK: Forest Public
  //
  public init () {
  }
  
  public func contains (index: TreeIndex<Value>) -> Bool {
    return contains (index.node)
  }

  public mutating func insert (value: Value) -> TreeIndex<Value> {
    let node = TreeNode<Value>(value: value)
    return TreeIndex (node: insert (node))
  }
  
  public mutating func insert (value: Value, parent index: TreeIndex<Value>) -> TreeIndex<Value>? {
    if let node = insert (TreeNode<Value>(value:value), parent: index.node) {
      return TreeIndex (node: node)
    }
    return nil
  }
  
  public mutating func removeAtIndex (index: TreeIndex<Value>) -> Tree<Value>? {
    if !contains(index.node) { return nil }
    else if let ri = roots.indexOf (index.node) {
      roots.removeAtIndex(ri)
      return Tree<Value> (root: index.node)
    }
    else {
      (index.node.parent as! TreeNode<Value>).remKid (index.node)
      return Tree<Value>(root: index.node)
    }
  }
  
  public mutating func link (kid: TreeIndex<Value>, parent: TreeIndex<Value>) {
    
  }
}
*/

