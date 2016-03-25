//
//  Queue.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

// MARK: - Queue Type

///
/// A QueueType is holds elements according to a FIFO discipline.  Elements are
/// enqueued and dequeued.
///
protocol QueueType {
  
  associatedtype Item
  
  /// Return the element at the head of the queue; if empty, return Optional.None
  var head : Item? { get }

  /// Return the element at the tail of the queue; if empty, return Optional.None
  var tail : Item? { get }
  
  /// Enqueue `item` to the tail of the queue.
  mutating func enqueue (_ item : Item)

  /// Dequeue `item` from the head of the queue
  mutating func dequeue () -> Item?

  /// Map over the queue
  ///
  /// - parameter transform: Function to apply to each `item`
  ///
  /// - returns: A Queue\<T\> with the results of applying `transform` to each `item`
  ///
  func map<T> ( _ transform: (Item) -> T) -> Queue<T>
}

// MARK: - Queue

///
/// A Queue holds elements according to a FIFO discipline; it is an OrderedBagType
///
public struct Queue<E> : QueueType {
  
  public typealias Item = E
  
  internal var objs : Array<Item>

  internal init (objs: Array<Item>) {
    self.objs = objs
  }
  
  /// Create an empty Stack
  public init () {
    self.objs = Array<Item>()
  }
  
  // Protocol QueueType
  
  /// Return the element at the head of the queue; if empty, return Optional.None
  public var head : Item? {
    return objs.first
  }
  
  /// Return the element at the tail of the queue; if empty, return Optional.None
  public var tail : Item? {
    return objs.last
  }
  
  /// Enqueue `item` to the tail of the queue.
  public mutating func enqueue (_ item : Item) {
    objs.append (item)
  }
  
  /// Dequeue `item` from the head of the queue
  public mutating func dequeue () -> Item? {
    if let result = objs.first {
      objs.remove(at: 0)
      return result
    }
    return nil
  }
  
  public func map<T> ( _ transform: (Item) -> T) -> Queue<T> {
    return Queue<T>(objs: objs.map(transform))
  }
}

// MARK: Queue as ArrayLiteralConvertible

///
/// A Queue is an ArrayLiteralConvertible
///
extension Queue : ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Item...) {
    objs = elements
  }
}

// MARK: Queue as BagType

///
/// A Queue is a BagType
///
extension Queue : BagType {
  
  public var count : Int {
    return objs.count
  }
  
  public var isEmpty : Bool {
    return objs.isEmpty
  }
  
  public func app (_ apply: (Item) -> Void) -> Void {
    objs.forEach(apply)
  }
  
  public func app (_ apply: (Item) throws -> Void) rethrows -> Void {
    try objs.forEach(apply)
  }
  
  public func filter ( _ includeElement: (Item) -> Bool) -> Queue<Item> {
    return Queue<Item> (objs: objs.filter (includeElement))
  }
  
  public var array : [Item] {
    return objs
  }

  public var list : List<Item> {
    return List<Item>(elements: objs)
  }
}

extension Queue where E : Equatable {
  public func contains (_ item: Item) -> Bool {
    return objs.contains (item)
  }
}

// MARK: Queue as Ordered Bag Type

///
/// A Queue is an OrderedBagType
///
extension Queue : OrderedBagType {
  public func reduce<Result>(_ initial: Result, combine: (Result, E) -> Result) -> Result {
    return objs.reduce (initial, combine)
  }
}
