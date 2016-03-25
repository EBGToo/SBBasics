//
//  Stack.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

// MARK: - StackType

/// 
/// A StackType is holds elements according to a LIFO discipline.  Elements are
/// pushed onto the top of a stack and popped off of the top. 
///
protocol StackType {
  
  associatedtype Item
  
  /// Return the element at the top of the stack; if empty, return Optional.None
  var top : Item? { get }
  
  /// Return the element at the bottom of the stack; if empty, return Optional.None
  var bottom : Item? {get }
  
  /// Push `item` onto the top of the stack.
  mutating func push (_ item: Item) -> Void
  
  /// Pop and return the item on the top of the stack; if empty, return Optional.None
  mutating func pop () -> Item?

  func map<U> (_ transform: (Item) -> U) -> Stack<U>
}


// MARK: - Stack

///
/// A Stack holds elements according to a LIFO discipline; it is an OrderedBagType
///
public struct Stack<E> : StackType {
  
  /// StackType.Item and ArrayLiteralConvertible.Item, presumably
  public typealias Item = E
  
  /// Objs in stack
  internal var objs : List<Item>

  /// Create an empty Stack
  public init () {
    self.objs = List<Item>()
  }

  ///
  /// Create a Stack instance with the provided list elements.  The list head will be the 
  /// stack top.
  /// 
  /// - parameter objs: Content of the stack
  ///
  internal init (objs: List<Item>) {
    self.objs = objs
  }

  // Protocal StackType
  
  /// Return the element at the top of the stack; if empty, return Optional.None
  public var top : Item? { return objs.car }
  
  /// Return the element at the bottom of the stack; if empty, return Optional.None
  public var bottom : Item? { return objs.last }
  
  /// Push `item` onto the top of the stack.
  public mutating func push (_ item : Item) -> Void {
    objs = List.cons (item, objs)
  }
  
  /// Pop and return the item on the top of the stack; if empty, return Optional.None
  public mutating func pop () -> Item? {
    if let result = objs.car {
      objs = objs.cdr!
      return result
    }
    return nil
  }

  public func map<U> ( _ transform: (Item) -> U) -> Stack<U> {
    return Stack<U> (objs: objs.map(transform))
  }
}

// MARK: Stack as ArrayLiteralConvertible

extension Stack : ExpressibleByArrayLiteral {
  
  ///
  /// Create a Stack instance with the provided elements ordered such that element[0] will the
  /// at the top of the stack and element[count-1] will be at the bottom
  ///
  /// - parameter arrayLiteral: Content of the stack
  ///
  public init (arrayLiteral elements: Item...) {
    objs = List<Item>(elements: elements)
  }
}

// MARK: - Stack as BagType

extension Stack : BagType {
  public var count : Int {
    return objs.count
  }
  
  public var isEmpty : Bool {
    return objs.isEmpty
  }

  public func app (_ apply: (Item) -> Void) -> Void {
    objs.app(apply)
  }
  
  public func app (_ apply: (Item) throws -> Void) rethrows -> Void {
    try objs.app(apply)
  }
  
  public func filter ( _ includeElement: (Item) -> Bool) -> Stack<Item> {
    return Stack<Item> (objs: objs.filter (includeElement))
  }
  
  public var array : [Item] {
    return objs.array
  }
  
  public var list : List<Item> {
    return objs
  }
}

extension Stack where E : Equatable {
  public func contains (_ item: Item) -> Bool {
    return objs.contains (item)
  }
}

// MARK: Stack as OrderedBagType

extension Stack : OrderedBagType {
  public func reduce<Result>(_ initial: Result, combine: (Result, E) -> Result) -> Result {
    return objs.foldl (initial, combine: combine)
  }
}
