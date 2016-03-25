//
//  Box.swift
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
// MARK: Box
//

public enum BoxColor {
  case white
  case gray
  case black
}


///
/// Box holds an `item` and an optional `parent`  A parent-less box is a `founder`.
/// This box is a base class for BoxedTree, BoxedBinaryTree and BoxedSearcher.
///
/// A Box is Equatable based on identity.
///
public class Box<Item> : Equatable {

  /// The color */
  public var color : BoxColor = .white

  /// The item */
  public let item : Item
  
  /// The parent
  public internal(set) var parent : Box<Item>?
  
  /// The oldest ancestor
  public var founder : Box<Item> {
    return parent?.founder ?? self //  nil == parent ? self : parent!.founder
  }
  
  /// A List of ancestors ordered from most recent to the oldest and excluding self
  public var ancestors : List<Box<Item>> {
    return nil == parent ? List() : List(parent!, parent!.ancestors)
  }
  
  /// Return true is a parent exists
  public var parentExists : Bool {
    return nil != parent
  }

  /// Return true is self has box as its parent.
  public func hasParent (_ box: Box<Item>) -> Bool {
    return box == parent
    //    return nil != parent && box == parent!
  }
  
  /// Return the number of ancestors.  The founder has a depth of zero
  public var depth : Int {
    return level - 1
  }

  /// Return the level which is 1 + the number of ancestor.  The founder has a
  /// level of one.
  public var level : Int {
    return 1 + (parent?.level ?? 0)
  }
  
  //! Create a ParentBox with the given parent.
  public init (item:Item, withParent parent: Box<Item>) {
    self.item = item
    self.parent = parent
  }

  /// Create a ParentBox as a founder
  public init (item:Item) {
    self.item = item
  }

}

// Equatable
public func == <Item> (lhs:Box<Item>, rhs:Box<Item>) -> Bool {
  return lhs === rhs
}

// ===========================================================================
//
// MARK: Box With Kids
//
//
/*
protocol BoxWithKids {
  
  //! The kids
  var kids : [BoxWithKids] { get }

  //! true is no kids; false otherwise
  var isWithoutKids : Bool { get }
  
  //! The number of kids
  var degree : Int { get }

  //! Apply funk to each kid
  func appKids (funk : ((BoxWithKids) -> Void)) -> Void

  //! The descendents
  var descendents : [BoxWithKids] { get }

  //! Apply funk to each descendent
  func appDescendents (funk : ((BoxWithKids) -> Void)) -> Void

  //! The number of descendents
  var size : Int { get }
  
  //! The longest count of descendents along any path.  A leaf (no kids) has
  //! a height of zero
  var height : Int { get }
}
*/

// ===========================================================================
//
// MARK: Boxed Tree
//

///
/// A BoxedTree is a Box that implements TreeType.  It has `kids`.
///
public final class BoxedTree<Item> : Box<Item> {
  
  public typealias Visitor = (Item) -> Void

  /// The kids
  public internal(set) var kids : [BoxedTree<Item>] = []

  public func addKid (_ kid : BoxedTree<Item>) {
    precondition(!kid.parentExists, "The kid \(kid) already has a parent")
    
    kid.parent = self
    kids.append(kid)
  }
  
  public func remKid (_ kid : BoxedTree<Item>) {
    if let index = kids.firstIndex(of: kid) {
      kid.parent = nil
      kids.remove(at: index)
    }
    else { preconditionFailure("The parent of kid \(kid) is not me.") }
  }
  
  public func hasKid (_ kid: BoxedTree<Item>) -> Bool {
    return nil != kids.firstIndex(of: kid)
  }
  
  public func appKids (_ f: (_ kid:BoxedTree<Item>) -> ()) {
    kids.app(f)
  }
  
  func reduceKids<U> (initial value: U, combine: (U, BoxedTree<Item>) -> U) -> U {
    var value = value
    appKids { value = combine (value, $0) }
    return value
  }

  public var descendents : [BoxedTree<Item>] {
    var result = Array<BoxedTree<Item>>()
    appDescendents { result.append($0) }
    return result
  }
  
  public func appDescendents (_ f: (_ d:BoxedTree<Item>) -> ()) {
    f (self)
    appKids { (kid) -> () in kid.appDescendents(f) }
  }
  
  // MARK: Successor (Depth First Pre-Order)
  
  func successorToKid (_ kid: BoxedTree<Item>) -> BoxedTree<Item>? {
    if let index = kids.firstIndex (of: kid) {
      return (index + 1 < kids.count
        ? kids[index + 1]
        : (parent as? BoxedTree<Item>)?.successorToKid(self))
    }
    else { preconditionFailure("The parent of kid \(kid) is not me.") }
  }
    
  public var successor : BoxedTree<Item>? {
    return isKidless
      ? (parent as? BoxedTree<Item>)?.successorToKid(self)
      : kids[0]
  }
  
  // MARK: Initialize
  
  
  /// Initialize an instance
  public init (item:Item, withParent parent: BoxedTree<Item>) {
    super.init(item: item, withParent: parent)
    self.parent = nil
    parent.addKid(self)
  }

  /// Initialize an instance
  public override init (item:Item) {
    super.init(item: item)
  }
}

// MARK: Boxed Tree as TreeType

extension BoxedTree : TreeType {
  
  public var isKidless : Bool {
    return kids.isEmpty
  }
  
  public var degree : Int {
    return kids.count
  }
  
  public var count : Int {
    return kids.reduce(1) { $0 + $1.count }
  }
  
  public var height : Int {
    return kids.isEmpty ? 0
      : kids.reduce(1) { return max ($0, $1.height) }
  }
  
  func lookup (_ item: Item, pred: (Item, Item) -> Bool) -> BoxedTree<Item>? {
    return nil
  }
  
  public func depth (_ item: Item, pred: (Item, Item) -> Bool) -> Int? {
    return lookup (item, pred: pred).map { $0.depth }
  }
  
  /** The parent of item if found based on `pred` */
  public func parent (_ item: Item, pred: (Item, Item) -> Bool) -> BoxedTree<Item>? {
    return lookup (item, pred: pred).flatMap { $0.parent as? BoxedTree }
  }
  
  public func walkByBreadth(preOrder: Visitor?, postOrder: Visitor?) {
    var queue = Queue<BoxedTree<Item>>()
    
    func walk (_ tree:BoxedTree<Item>) {
      preOrder? (tree.item)
      
      tree.kids.forEach {
        queue.enqueue($0)
      }
      
      _ = queue.dequeue().map(walk)
      
      postOrder?(tree.item)
    }
    
    walk(self)
  }
  
  public func walkByDepth (preOrder: Visitor?, inOrder: Visitor?, postOrder: Visitor?) {
    func rwalk (_ t: BoxedTree<Item>) {
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
    
  /** All items */
  public var array : Array<Item> {
    //return kids.map { $0.items }.reduce([item]) { $0.appendContentsOf($1) }
    
    var result = [item]
    kids.map { $0.array }.forEach { result.append(contentsOf: $0) }
    return result
  }
  
  public func contains (_ item: Item, pred: (Item, Item) -> Bool) -> Bool {
    return pred (self.item, item)
      || kids.any { $0.contains (item, pred: pred) }
  }
}

// ===========================================================================
//
// MARK: Binary Box
//

///
/// A BinaryBox is a Box that implemnets BinaryTreeType
///
public final class BinaryBox<Item:Comparable> : Box<Item> {
  
  //public typealias BinaryBox = BinaryBox<Item>
  public typealias Visitor = (Item) -> Void

  public var root : BinaryBox<Item>? {
    get { return parent as! BinaryBox<Item>? }
    set { parent = newValue }
  }
  
  //
  //
  //
  public var left  : BinaryBox<Item>?
  
  public func hasLeft (_ left: BinaryBox<Item>) -> Bool {
    return nil != self.left && self.left! === left
  }
  
  public func addLeft (_ left: BinaryBox<Item>) {
    if nil != self.left { remLeft() }
    self.left = left
    left.root = self
  }
  
  public func remLeft () {
    if let left = self.left {
      left.root = nil
      self.left = nil
    }
  }

  // Make BOX be LEFT.  Combines remLeft(), when SELF.LEFT exists, and addLeft()
  internal func spliceAtLeft (_ box: BinaryBox<Item>) -> BinaryBox<Item>? {
    let old = self.left
    
    if nil != old { old!.root = nil }
    addLeft (box)
    
    return old
  }
  
  //
  //
  //
  public var right : BinaryBox<Item>?
  
  public func hasRight (_ right: BinaryBox<Item>) -> Bool {
    return nil != self.right && self.right! === right
  }
  
  public func addRight (_ right: BinaryBox<Item>) {
    if nil != self.right { remRight () }
    self.right = right
    right.root = self
  }

  public func remRight () {
    if let right = self.right {
      right.root = nil
      self.right = nil
    }
  }

  //
  // Make BOX be RIGHT.  Combines remRight(), when SELF.RIGHT exsits, and
  // addRight()
  //
  internal func spliceAtRight (_ box : BinaryBox<Item>) -> BinaryBox<Item>? {
    let old = self.right
    
    if nil != old { old!.root = nil }
    addRight(box)
    
    return old
  }

  //
  // TODO
  internal func rotateRight () -> BinaryBox<Item>? {
    let root = self.root
    let left = self.left! // assumed?!
    
    // We are the Root's Left
    let roots_left = nil != root && self === root!.left
    
    _ = self.spliceAtLeft  (left.right!) // assumed?!
    _ = left.spliceAtRight (self)
  
    if nil != root {
      if roots_left { _ = root!.spliceAtLeft(left) }
      else { _ = root!.spliceAtRight(left) }
    }
    return left
  }
  
  /*
  - (SBRootBox *) rotateRight
  {
  SBRootBox
  *root  = self.root,
  *left  = self.left;
  
  Boolean roots_left = (self == root.left);
  
  [self spliceAtLeft:  left.right];
  [left spliceAtRight: self];
  
  if (root)
  (roots_left
  ? [root spliceAtLeft:  left]
  : [root spliceAtRight: left]);
  
  return left;
  }
*/
  //
  //
  //
  public func hasLeftOrRight (_ box: BinaryBox<Item>) -> Bool {
    return hasLeft (box) || hasRight (box)
  }
  
  public func hasLeftAndRight (_ left: BinaryBox<Item>, right: BinaryBox<Item>) -> Bool {
    return hasLeft(left) && hasRight(right)
  }

  //
  //
  //
  public init (item:Item, left: BinaryBox<Item>? = nil, right: BinaryBox<Item>? = nil) {
    super.init (item:item)
    // splice
  }
  
  // 
  // Box With Kids
  //
  
  func appKids (_ funk : ((BinaryBox<Item>) -> Void)) {
    if nil != left  { funk (left!)  }
    if nil != right { funk (right!) }
  }
  
  var descendents : [BinaryBox<Item>] {
    assertionFailure("Unimplemented")
      return []
//    return [left, right].filter { nil != $0 }
//      .flatMap { (b:BinaryBox<Item>?) -> [BinaryBox<Item>] in
//        [b!].append (b!.descendents)
    //    }
  }
  
  func appDescendents (_ funk : ((BinaryBox<Item>) -> Void)) {
    assertionFailure("Unimplemented")
    return
  }
  
  
  public var origin : BinaryBox<Item> {
    return root?.origin ?? self
    //return nil == root ? self : root!.origin
  }

  // MARK: Successor // Predecessor
  
  internal var upLeftOfRoot : BinaryBox<Item>? {
    if let root = self.root {
      return nil != root.left && self === root.left!
        ? root
        : root.upLeftOfRoot
    }
    else { return nil }
  }
  
  public var successor : BinaryBox<Item> {
    return nil == right ? upLeftOfRoot! : right!.minimum
  }
  
  var upRightOfRoot : BinaryBox<Item>? {
    if let root = self.root {
      return nil != root.right && self === root.right!
        ? root
        : root.upRightOfRoot
    }
    else { return nil }
  }
  
  public var predecessor : BinaryBox<Item> {
    return left?.maximum ?? upRightOfRoot!
  }
  
  // MARK: Lookup
  
  internal func lookup (_ item: Item) -> BinaryBox<Item>? {
    if self.item < item { return left?.lookup(item) }
    if self.item > item { return right?.lookup(item) }
    return self
  }
  
  //
  //
  //
  public func hasValue (_ item: Item, pred: (Item, Item) -> Bool) -> Bool {
    return pred (self.item, item) ||
      (nil != left  && left! .hasValue(item, pred: pred)) ||
      (nil != right && right!.hasValue(item, pred: pred))
  }

}

// MARK: BinaryBox as TreeType

extension BinaryBox : TreeType {
  
  public var kids : [BinaryBox<Item>] {
    return [left, right].filter { nil != $0 }.map {return $0! }
  }
  
  public var isKidless : Bool {
    return nil == left && nil == right
  }
  
  public var degree : Int {
    return (nil == left ? 0 : 1) + (nil == right ? 0 : 1)
  }

  public var count : Int {
    return ((nil == left  ? 0 : 1 + left!.count) +
      (nil == right ? 0 : 1 + right!.count))
  }
  
  //  public var depth : Int {
  //    return nil == root ? 1 : 1 + root!.depth
  //  }
  
  public var height : Int {
    return max ((nil == left  ? 0 : 1 + left!.height),
      (nil == right ? 0 : 1 + right!.height))
  }
 
  public func depth (_ item: Item, pred: (Item, Item) -> Bool) -> Int? {
    return 0
  }
  
  /** The parent of item if found based on `pred` */
  public func parent (_ item: Item, pred: (Item, Item) -> Bool) -> BinaryBox<Item>? {
    return nil
  }
  
  public func contains (_ item: Item, pred: (Item, Item) -> Bool) -> Bool {
    return false
  }

  public func walkByBreadth(preOrder: Visitor?, postOrder: Visitor?) {
    var queue = Queue<BinaryBox<Item>>()
    
    func walk (_ tree:BinaryBox<Item>) {
      preOrder? (tree.item)
      
      tree.kids.forEach {
        queue.enqueue($0)
      }
      
      _ = queue.dequeue().map(walk)
      
      postOrder?(tree.item)
    }
    
    walk(self)
  }
  
  /** */
  public func walkByDepth (preOrder: Visitor?, inOrder: Visitor?, postOrder: Visitor?) {
    func rwalk (_ t: BinaryBox<Item>) {
      t.walkByDepth (preOrder: preOrder, inOrder: inOrder, postOrder: postOrder)
    }
    
    if let l = left { preOrder?(item); rwalk(l) }
    inOrder? (item)
    if let r = right { rwalk(r); postOrder?(item) }
  }
  
  /** All items */
  public var array : Array<Item> {
    return []
  }
}

// MARK: BinaryBox as BinaryTreeType

extension BinaryBox : BinaryTreeType {
  public func contains (_ item: Item) -> Bool {
    return false
  }
  
  /// Depth (number of parents) to `item` (if it exists), otherwise nil
  public func depth (_ item: Item) -> Int? {
    return nil
  }
  
  /// The parent of `item` (if it exists), otherwise nil
  public func parent (_ item: Item) -> BinaryBox<Item>? {
    return nil
  }
  
  /// The subtree (kidless, leaf) to the left
  public var minimum : BinaryBox<Item> {
    return left ?? self
  }
  
  /// The subtree (kidless, leaf) to the right
  public var maximum : BinaryBox<Item> {
    return right ?? self
  }
  
  public func successor (_ item: Item) -> BinaryBox<Item>? {
    return lookup(item)?.successor ?? self
  }

  public func predecessor (_ item: Item) -> BinaryBox<Item>? {
    return lookup(item)?.predecessor ?? self
  }
}

//
//
//

// ===========================================================================
//
// MARK: SearchBox
//

/*
public class ZSearchBox<Item> : BoxedTree<Item> {
  var d : UInt = UInt.max
  var f : UInt = UInt.max
  
  public override init (item:Item) {
    super.init(item: item)
  }
}
*/

/*
//
// Search
//
class SearcherBox /* : ParentBox */ {
var c : String // color
var d : Int
var f : Int

init (node: Node<N>) {
// super.init ()
self.c = "White"
self.d = Int.max
self.f = Int.max
}

private func searcherBoxUpdate (c: String, d: Int, f: Int) {
self.c = c
self.d = d
self.f = f
}
}
*/
