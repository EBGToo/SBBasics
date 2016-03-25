//
//  Tree.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Opus Logica Inc. All rights reserved.
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
  func depth (item: Item, pred: (Item, Item) -> Bool) -> Int?
  
  /// The parent of item if found based on `pred`
  func parent (item: Item, pred: (Item, Item) -> Bool) -> Self?
  
  /// Check if `item`, based on `pred`, exists
  func contains (item: Item, pred: (Item, Item) -> Bool) -> Bool

  func walkByDepth (preOrder preOrder: Visitor?, inOrder: Visitor?, postOrder: Visitor?)
  
  func walkByBreadth (preOrder preOrder: Visitor?, postOrder: Visitor?)
  
  /// All items
  var array : Array<Item> { get }
}

extension TreeType {
  func walkByDepth (inOrder: Visitor) {
    walkByDepth(preOrder: nil, inOrder: inOrder, postOrder: nil)
  }
  
  func walkByBreadth(preOrder: Visitor) {
    walkByBreadth(preOrder: preOrder, postOrder: nil)
  }

  // descendents
  // kidsApp
  // kidsMap
  // kidsReduce
  // func parent<I:Equatable where Item == I> (item: I)
}

extension TreeType where Item:Equatable {
  func contains (item:Item) -> Bool {
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
    return kids.map { $0.count }.reduce(1, combine: +)
  }
  
  public var height : Int {
    return kids.isEmpty ? 0 : (1 + kids.map { $0.height }.reduce (Int.min, combine: max))
  }
  
  public func depth (item: Item, pred: (Item, Item) -> Bool) -> Int? {
    if pred (self.item, item) { return 0 }
    
    let result = kids.flatMap { $0.depth (item, pred: pred) }
      .reduce (Int.max, combine: min)
  
    return result == Int.max ? nil : 1 + result
  }
  
  /// The parent of item if found based on `pred`
  public func parent (item: Item, pred: (Item, Item) -> Bool) -> Tree? {
    if kids.any ({ pred ($0.item, item) }) { return self }
    else {
      return kids.flatMap { $0.parent (item, pred: pred) }.first
    }
  }
  
  public func contains (item: Item, pred: (Item, Item) -> Bool) -> Bool {
    return pred (self.item, item) || kids.any { $0.contains (item, pred: pred) }
  }

  ///
  public func walkByBreadth(preOrder preOrder: Visitor?, postOrder: Visitor?) {
    var queue = Queue<Tree<Item>>()

    func walk (tree:Tree<Item>) {
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
  public func walkByDepth (preOrder preOrder: Visitor?, inOrder: Visitor?, postOrder: Visitor?) {
    func rwalk (t: Tree<Item>) {
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
    kids.map { $0.array }.forEach { result.appendContentsOf($0) }
    return result
  }
}

// ===============================================================================================

// MARK: Binary Tree Type

///
/// A BinaryTreeType is a TreeType ...
///
public protocol BinaryTreeType : TreeType { //OrderedBagType
  associatedtype Item:Comparable
  
  /// The `left` subtree otherwise `nil`
  var left :  Self? { get }
  
  /// The `right` subtree, otherwise `nil`
  var right : Self? { get }
  
  /// Check if `item` is contained
  func contains (item: Item) -> Bool
  
  /// Depth (number of parents) to `item` (if it exists), otherwise nil
  func depth (item: Item) -> Int?
 
  // Restore: Self -> BinaryTree<Item>
  
  /// The parent of `item` (if it exists), otherwise nil
  func parent (item: Item) -> Self?
 
  /// The subtree (kidless, leaf) to the left
  var minimum : Self { get }
  
  /// The subtree (kidless, leaf) to the right
  var maximum : Self { get }

  /// The successor to `item` (if it exists), otherwise nil
  func successor (item: Item) -> Self?
  
  /// The predecessor to `item` (if it exists), otherwise nil
  func predecessor (item: Item) -> Self?
}

// MARK: Binary Tree

/// A `Color` is used to balance a binary tree: Red and Black
public enum Color { case R, B }

/// A `Order` defines a sub-search order; under .Breadth or .Depth
public enum Order { case PreOrder, InOrder, PostOrder }

///
/// A BinaryTree is an ordered set of Items

public enum BinaryTree<Item: Comparable> : BinaryTreeType {
  
  // Resursive Base - this is not exposed in a public interface (except this type itself)
  case Empty
  
  // Recursive Tree - Note: a `leaf` is .Node (_, .Empty, _, .Empty)
  indirect case Node(Color, BinaryTree<Item>, Item, BinaryTree<Item>)
  
  public typealias Visitor = (Item) -> Void
  
  private init () {
    self = .Empty
  }
  
  private init(item: Item,
    color: Color = .B,
    left : BinaryTree<Item> = .Empty,
    right: BinaryTree<Item> = .Empty)
  {
    self = .Node(color, left, item, right)
  }
  
  /// Initialize an instance as a `Leaf` with `item`
  public init (_ item: Item) {
    self.init (item: item)
  }

  /// Initialize an instance with `items`
  init (items: Array<Item>) {
    // By doing this, for a random array of N ~= 1000, speed up by x20
    var items = items.sort()

    func recolor (color: Color) -> Color {
      switch color {
      case .R: return .B
      case .B: return .R
      }
    }
    
    func split (color: Color, _ items: ArraySlice<Item>) -> BinaryTree<Item> {
      let xolor = recolor (color)

      switch items.count {
      case 0: return .Empty
      case 1:
        let item = items[items.startIndex]

        return .Node(color, .Empty, item, .Empty)

      case 2:
        let litem = items[items.startIndex]
        let hitem = items[items.startIndex + 1]

        return .Node(color, .Empty, litem, .Node(xolor, .Empty, hitem, .Empty))
        
      case 3:
        let litem = items[items.startIndex]
        let mitem = items[items.startIndex + 1]
        let hitem = items[items.startIndex + 2]

        return .Node(color, .Node(xolor, .Empty, litem, .Empty), mitem, .Node(xolor, .Empty, hitem, .Empty))

      default:
        let ldex = items.startIndex
        let edex = items.endIndex
        let mdex = (edex + ldex) / 2

        let ltree = split (xolor, items[ldex..<mdex])
        let rtree = split (xolor, items[(mdex + 1)..<edex])

        return .Node(color, ltree, items[mdex], rtree)
      }
    }
    
    self = split (.B, items[0..<items.count])
  }
  
  @noreturn
  private func unexpectedEmpty () {
    preconditionFailure("BinaryTree at .Empty unexpectedly.")
  }
  
  /// The `item`
  public var item : Item {
    switch self {
    case Empty: unexpectedEmpty()
    case let Node (_, _, item, _): return item
    }
  }
  
  /// The `left` subtree otherwise `nil`
  public var left : BinaryTree<Item>? {
    switch self {
    case .Node (_, .Empty, _, _): return nil
    case .Node (_, let l , _, _): return l
    case .Empty: unexpectedEmpty()
    }
  }
  
  /// The `right` subtree, otherwise `nil`
  public var right : BinaryTree<Item>? {
    switch self {
    case .Node (_, _, _, .Empty): return nil
    case .Node (_, _, _, let r ): return r
    case .Empty: unexpectedEmpty()
    }
  }
  
  /// The `kids` - composed of `left` and `right` nodes, that exist.
  public var kids : Array<BinaryTree<Item>> {
    switch self {
    case .Node(_, .Empty, _, .Empty): return []
    case let .Node (_, .Empty, _, r): return [r]
    case let .Node (_, l, _, .Empty): return [l]
    case let .Node (_, l, _, r): return [l, r]
    case .Empty: unexpectedEmpty()
    }
  }

  /// `true` if no `kids`; otherwise `false` - aka `isLeaf`
  public var isKidless : Bool {
    switch self {
    case .Empty: unexpectedEmpty()
    case .Node (_, .Empty, _, .Empty): return true
    default: return false
    }
  }
  
  /// The number of kids
  public var degree : Int {
    switch self {
    case .Empty: unexpectedEmpty()
    case .Node (_, .Empty, _, .Empty): return 0
    case .Node (_, .Node,  _, .Node ): return 2
    default: return 1
    }
  }
  
  /// The number of descendents (includes self)
  public var count : Int {
    switch self {
    case Empty: return 0
    case let Node (_, l, _, r):
      return 1 + l.count + r.count
    }
  }
  
  /// The longest count of descendents along any path.  A leaf (no kids) has a height of zero
  public var height : Int {
    switch self {
    case Empty: return -1
    case let Node (_, l, _, r):
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
  public func depth(item: Item, pred: (Item, Item) -> Bool) -> Int? {
    switch self {
    case let .Node (_, .Node(_, _, that, _), _, _)  where pred (that, item): return 1
    case let .Node (_, _, _, .Node (_, _, that, _)) where pred (that, item): return 1
    case let .Node (_, l, that, r):
      // Caution on `pred` implies `==` but isn't `==`
      if item < that { return l.depth (item, pred: pred).map { 1 + $0 } }
      if item > that { return r.depth (item, pred: pred).map { 1 + $0 } }
      return 0
    case .Empty: unexpectedEmpty()
    }
  }
  
  /// The parent of item if found based on `pred`
  public func parent (item: Item, pred: (Item, Item) -> Bool) -> BinaryTree<Item>? {
    switch self {
    case let .Node (_, _, this, _) where pred (this, item): return nil
    case let .Node (_, .Node(_, _, that, _), _, _)  where pred (that, item): return self
    case let .Node (_, _, _, .Node (_, _, that, _)) where pred (that, item): return self
    case let .Node (_, l, _, r):
      return l.parent (item) ?? r.parent (item)
    case .Empty: unexpectedEmpty()
    }
  }

  /// Check if `item`, based on `pred`, exists
  public func contains(item: Item, pred: (Item, Item) -> Bool) -> Bool {
    switch self {
    case .Empty: return false
    case let .Node (_, l, that, r):
      return pred (that, item)
        || l.contains (item, pred: pred)
        || r.contains (item, pred: pred)
    }
  }

  public func walkByBreadth(preOrder preOrder: Visitor?, postOrder: Visitor?) {
    var queue = Queue<BinaryTree<Item>>()
    
    func walk (tree:BinaryTree<Item>) {
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
  public func walkByDepth (preOrder preOrder: Visitor?, inOrder: Visitor?, postOrder: Visitor?) {
    func rwalk (t: BinaryTree<Item>) {
      t.walkByDepth (preOrder: preOrder, inOrder: inOrder, postOrder: postOrder)
    }

    switch self {
    case .Empty: return
    case let Node (_, l, item, r):
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
    if let l = left  { result.appendContentsOf(l.array) }
    if let r = right { result.appendContentsOf(r.array) }
    return result
  }
  
  //
  // MARK: Binary Tree Type Implementation
  //
  
  /// Check if `item` is contained
  public func contains(item: Item) -> Bool {
    return nil != lookup(item)
  }
  
  /// Depth (number of parents) to `item` (if it exists), otherwise nil
  public func depth (item: Item) -> Int? {
    switch self {
    case .Empty: return nil
    case let .Node(_, l, that, r):
      if item < that { return l.depth (item).map { 1 + $0 } }
      if item > that { return r.depth (item).map { 1 + $0 } }
      return 0
    }
  }
  
  /// The parent of `item` (if it exists), otherwise nil
  public func parent (item: Item) -> BinaryTree<Item>? {
    switch self {
    case .Empty: return nil
    case let .Node (_, .Node(_, _, that, _), _, _)  where that == item: return self
    case let .Node (_, _, _, .Node (_, _, that, _)) where that == item: return self
    case let .Node (_, l, that, r):
      if item < that { return l.parent (item) }
      if item > that { return r.parent (item) }
      return nil
    }
  }
  
  /// The subtree (kidless, leaf) to the left
  public var minimum : BinaryTree<Item> {
    switch self {
    case .Node (_, .Empty, _, _): return self
    case .Node (_, let l,  _, _): return l.minimum
    case .Empty: unexpectedEmpty()
    }
  }
  
  /// The subtree (kidless, leaf) to the right
  public var maximum : BinaryTree<Item> {
    switch self {
    case .Node (_, _, _, .Empty): return self
    case .Node (_, _, _, let r ): return r.maximum
    case .Empty: unexpectedEmpty()
    }
  }

  func lookup (item: Item) -> BinaryTree<Item>? {
    switch self {
    case .Empty: return nil
    case let .Node(_, l, that, r):
      if item < that { return l.lookup (item) }
      if item > that { return r.lookup (item) }
      return self
    }
  }
  
  private typealias Box = BinaryTree<Item>
  
  private func lookup (item: Item, path: List<Box>, done: (path: List<Box>) -> Box?) -> Box? {
    switch self {
    case let .Node (_, l, that, r):
      if item < that { return l.lookup (item, path: List<Box>(self, path), done: done) }
      if item > that { return r.lookup (item, path: List<Box>(self, path), done: done) }
      return done (path: List<Box>(self, path))
    case .Empty: return done (path: List<Box>.Nil)
    }
  }

  private func upRight (path: List<Box>) -> Box? {
    guard let parent = path.car else { return nil }
    if parent.right?.item == item { return parent }
    else { return parent.upRight (path.cdr!) }
  }

  private func upLeft (path: List<Box>) -> Box? {
    guard let parent = path.car else { return nil }
    if parent.left?.item == item { return parent }
    else { return parent.upLeft (path.cdr!) }
  }
  
  public func predecessor (item: Item) -> BinaryTree<Item>? {
    return lookup (item, path: .Nil) { (path:List<Box>) -> Box? in
      guard case let .Cons(box, rest) = path else { return nil } // Item not found
      return box.left?.maximum ?? box.upRight(rest)
    }
  }
  
  public func successor (item: Item) -> BinaryTree<Item>? {
    return lookup (item, path: .Nil) { (path:List<Box>) -> Box? in
      guard case let .Cons(box, rest) = path else { return nil } // Item not found
      return box.right?.minimum ?? box.upLeft(rest)
    }
  }
    
  // MARK: Insert
  
  public func insertNew (item: Item) -> BinaryTree<Item> {
    func ins (this: BinaryTree<Item>, _ item: Item) -> BinaryTree<Item> {
      switch this {
      case Empty: return BinaryTree (item: item, color: .R)
      case let Node (color, left, that, right):
        if item < that { return BinaryTree (item: that, color: color, left: ins(left, item), right: right).balance() }
        if item > that { return BinaryTree (item: that, color: color, left: left, right: ins(right, item)).balance() }
        return self
      }
    }
    
    switch ins (self, item) {
    case Empty: fatalError ("impossible")
    case let Node (_, left, item, right):
      return .Node(.B, left, item, right)
    }
  }
  
  public mutating func insert (item: Item) {
    self = insertNew (item)
  }
  
  private func balance() -> BinaryTree<Item> {
    switch self {
    case let .Node(.B, .Node(.R, .Node(.R, a, x, b), y, c), z, d):
      return .Node(.R, .Node(.B,a,x,b), y, .Node(.B,c,z,d))
      
    case let .Node(.B, .Node(.R, a, x, .Node(.R, b, y, c)), z, d):
      return .Node(.R, .Node(.B,a,x,b), y, .Node(.B,c,z,d))
      
    case let .Node(.B, a, x, .Node(.R, .Node(.R, b, y, c), z, d)):
      return .Node(.R, .Node(.B,a,x,b), y, .Node(.B,c,z,d))
      
    case let .Node(.B, a, x, .Node(.R, b, y, .Node(.R, c, z, d))):
      return .Node(.R, .Node(.B,a,x,b), y, .Node(.B,c,z,d))
      
    default:
      return self
    }
  }
  
  // MARK: Delete

  public func deleteNew (item: Item) -> BinaryTree<Item> {
    switch self {
    case .Empty: return .Empty
      
      // Right That Leaf
    case let .Node (pc, pl, pi, .Node (_, .Empty, that, .Empty)) where that == item:
      return .Node (pc, pl, pi, .Empty)

      // Left That Leaf
    case let .Node (pc, .Node (_, .Empty, that, .Empty), pi, pr) where that == item:
      return .Node (pc, .Empty, pi, pr)

      // Right That w/ Left Only
    case let .Node (pc, pl, pi, .Node (_, tl, that, .Empty)) where that == item:
      return .Node (pc, pl, pi, tl)
      
      // Right That w/ Right Only
    case let .Node (pc, pl, pi, .Node (_, .Empty, that, tr)) where that == item:
      return .Node (pc, pl, pi, tr)

      // Left That w/ Left Only
    case let .Node (pc, .Node (_, tl, that, .Empty), pi, pr) where that == item:
      return .Node (pc, tl, pi, pr)

      // Left That w/ Right Only
    case let .Node (pc, .Node (_, .Empty, that, tr), pi, pr) where that == item:
      return .Node (pc, tr, pi, pr)

      // Left That w/ Left and Right
    case let .Node (pc, pl, pi, .Node (tc, tl, that, tr)) where that == item:
      let succ = tr.minimum.item
      return .Node (pc, pl, pi, .Node (tc, tl, succ, tr.deleteNew(succ))) // rebalance if tr.minimum .B

      // Right That w/ Left and Right
    case let .Node (pc, .Node (tc, tl, that, tr), pi, pr) where that == item:
      let succ = tr.minimum.item
      return .Node (pc, .Node (tc, tl, succ, tr.deleteNew(succ)), pi, pr) // rebalance if tr.minimum .B

      // Self That w/ Left Only
    case let .Node (_, l, that, .Empty) where that == item:
      return l

      // Self That w/ Left and Right
    case let Node (c, l, that, r):
      if item < that { return BinaryTree (item: that, color: c, left: l.deleteNew(item), right: r) }
      if item > that { return BinaryTree (item: that, color: c, left: l, right: r.deleteNew(item)) }

      let succ = r.minimum.item // r exists
      return .Node (c, l, succ, r.deleteNew (succ))
    }
  }
  
  public mutating func delete (item: Item) {
    self = deleteNew (item)
  }
}

extension BinaryTree : ArrayLiteralConvertible {
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

