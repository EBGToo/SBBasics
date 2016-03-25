//
//  Bag
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

// MARK: BagType

///
/// A BagType defines a minimalistic, narrowly-interfaced container protocol for an arbitrary number
/// of specifically typed but otherwise arbitary Items.  A Bag may hold numerous 'duplicate' items.
/// Generally the ordering of items in a bag is upspecified and the contents of the bag are (meant
/// to be) invisible.  One does not sequence through the bag contents nor does one index into the
//  bag.  There are other Swift data structures that allow for sequencing and indexing.
///
public protocol BagType {
  
  /// The type for elements in the bag
  associatedtype Item
  
  /// The number of elements in the bag.
  var count   : Int  { get }
  
  /// Returns `true` if and only if the bag is empty; `false` otherwise.
  var isEmpty : Bool { get }

  /// Return the items as an array
  var array : Array<Item> { get }
  
  /// Return the items as a list
  var list : List<Item> { get }
  
  // mutating func clear ()

  /// Apply `body` to each item in the `Bag` */
  func app ( _ body: (Item) throws  -> Void) rethrows -> Void

  /// Return a new `Bag` with the items that satisfy `includeElement`.
  func filter ( _ includeElement: (Item) -> Bool) -> Self
  // Note: Prevents `TreeType` from being a BagType

  /// Return a new `Bag` with items created by applying `transform`
  //func map<U> (@noescape transform : (Item) -> U) -> BagType
}

extension BagType where Item:Equatable {
  
  /// Return `true` if the bag contains `item`, `false` otherwise.
  public func contains (_ item: Item) -> Bool {
    var found = false
    app { found = found || (item == $0) }
    return found
  }
}

extension BagType {
  
  // Default implementation
  public var list : List<Item> {
    return List<Item>(elements: self.array)
  }
}

// MARK: OrderedBagType

///
/// An OrderedBagType is a BagType with a specfied ordering of items.  Functions for `app`, `map`
/// and `reduce` visit items in order.
///
public protocol OrderedBagType : BagType {

  /// 
  /// Return the `Result` of applying `combine` to each item in the bag
  ///
  /// - parameter initial:
  /// - parameter combine:
  ///
  /// - returns 
  ///
  func reduce<Result>(_ initial: Result, combine: (Result, Item) -> Result) -> Result
}

extension OrderedBagType {
  
  // Default implementation
  public func reduce<Result>(_ initial: Result, combine: (Result, Item) -> Result) -> Result {
    var initial = initial
    app { initial = combine (initial, $0) }
    return initial
  }
}

// MARK: Bag as BagType

///
/// A Bag holds an arbitrary number of items per BagType
///
public struct Bag<E> : BagType {
  public typealias Item = E
  
  var items : Array<Item>
  
  /// Create in instance holding `items`
  private init (items: Array<Item>) {
    self.items = items
  }
  
  /// Create an instance with no items
  public init () {
    self.items = Array<Item>()
  }
  
  /// The number of elements in the bag.
  public var count : Int {
    return items.count
  }
  
  /// Returns `true` if and only if the bag is empty; `false` otherwise.
  public var isEmpty : Bool {
    return items.isEmpty
  }
    
  /** Apply `body` to each item in the `Bag` */
  public func app (_ body: (Item) throws -> Void) rethrows -> Void {
    try items.forEach(body)
  }
  
  /// Return a new `Bag` with the items that satisfy `includeElement`
  public func filter ( _ includeElement: (Item) -> Bool) -> Bag<Item> {
    return Bag<Item> (items: items.filter (includeElement))
  }
  
  /// Return the items as an array
  public var array : [Item] {
    return items
  }
  
  /// Return the items as a list
  public var list : List<Item> {
    return List<Item>(elements: items)
  }
  
  // Bag 
  
  /// Add `item`
  public mutating func insert (_ item:Item) {
    items.append(item)
  }
  
  /// Remove an arbitrary item
  public mutating func removeAny () {
    if !items.isEmpty {
      items.removeLast()
    }
  }
  
  ///
  /// Remove any one object satisfying `predicate`.
  ///
  /// - parameter predicate: The function used to identify an object
  ///
  /// - returns: true if an object was removed, false otherwise
  ///
  public mutating func removeIf (_ predicate: (Item) -> Bool) -> Bool {
    if let index = items.firstIndex (where: predicate) {
      items.remove(at: index)
      return true
    }
    return false
  }
}

extension Bag : ExpressibleByArrayLiteral {
  
  /// Create in instance holding `items`
  public init(arrayLiteral elements: Item...) {
    self.items = elements
  }
}

// MARK: Bag where E:Equatable

///
/// A Bag with Equatable Elements
///
extension Bag where E:Equatable {
  
  /// Remove `item` if it exists and return true; otherwise return false
  public mutating func remove (_ item:Item) -> Bool {
    return removeIf { $0 == item }
  }

  /// Return `true` if the bag contains `item`, `false` otherwise.
  public func contains (_ item: Item) -> Bool {
    return items.contains(item)
  }
}
