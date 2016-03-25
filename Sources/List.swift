//
//  List.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

// MARK: ListType

///
/// The ListBaseType protocol declares `car` and `cdr` as properties 
///
public protocol ListBaseType {
  
  /// The `Item` type
  associatedtype Item
  
  /// The `car` is the list's head item
  var car : Item? { get }
  
  /// The `cdr` is the list's tail
  var cdr : Self? { get }
}

///
/// A ListType holds arbitary `Items` using a list discipline whereby either the list is
/// empty or the list had a pair of (car, cdr) where the `car` it the item at the head of the
/// list and the `cdr` is the rest of the list.
///
public protocol ListType : ListBaseType, BagType {

  /// 
  /// Partition the list into two based on `pred`
  ///
  /// - parameter pred: The predicate
  /// - returns: A 2-tuple of lists - the first list contains the items that satisfied `pred`;
  ///    the second list contains those items the failed `pred`.
  ///
  func partition (_ pred: (Item) -> Bool) -> (List<Item>, List<Item>)

  ///
  /// - parameter initial:
  /// - parameter combine:
  /// - returns:
  ///
  func foldl<S> (_ initial: S, combine: (S, Item) -> S) -> S

  ///
  ///
  
  ///
  /// - parameter initial:
  /// - parameter combine:
  /// - returns:
  ///
  func foldr<S> (_ initial: S, combine: (Item, S) -> S) -> S

  ///  Check if `any` Item satisfies `predicate`
  func any ( _ predicate: (Item) -> Bool) -> Bool

  /// Check if `all` Items satisfy `predicate`
  func all ( _ predicate: (Item) -> Bool) -> Bool

  /// Check if `self` and `that` have idential Items compared with `pred`
  func equalToList (_ that: List<Item>, pred: (Item, Item) -> Bool) -> Bool

  /// A list with items reversed
  var reverse : Self { get }
  
  /// The first item or Optional.None
  var first : Item? { get }
  
  /// The last item or Optional.None
  var last : Item? { get }

  /// A list with the items that satisfy `includeElement`
  func filter ( _ includeElement: (Item) -> Bool) -> List<Item>
  
  /// A list with `transform` applied to each item
  func map<U> ( _ transform: (Item) -> U) -> List<U>

  /// A Lazy list
  var lazy : LazyList<List<Item>> { get }
}

// MARK: List


/// A List
public enum List<T> : ListType {
  case none
  indirect case cons (T, List<T>)
  
  public typealias Item = T
  
  public var car : T? {
    switch self {
    case .none: return nil
    case .cons (let car, _): return car
    }
  }
  
  public var cdr : List<T>? {
    switch self {
    case .none: return nil
    case .cons (_, let cdr): return cdr
    }
  }
  
  
  // MARK: Init
  
  public init (elements: [T]) {
    self = .none
    for elt in elements.reversed() {
      self = .cons(elt, self)
    }
  }
  
  public init () {
    self = .none
  }
  
  public init (_ car: T) {
    self = .cons (car, .none)
  }
  
  public init (_ car: T, _ cdr: List<T>) {
    self = .cons (car, cdr)
  }
  
  public var first : T? {
    switch self {
    case .none: return nil
    case let .cons (car, _): return car
    }
  }
  
  public var last : T? {
    switch self {
    case .none: return nil
    case let .cons (car, .none): return car
    case let .cons (_, cdr):
      return cdr.last
    }
  }
  
  public subscript(n:Int) -> T? {
    switch self {
    case .none: return nil
    case let .cons (car, cdr):
      return (0 == n ? car : cdr[n - 1])
    }
  }

  // MARK: Map, Filter, Reverse, Partition -> List
  
  private func rmapping<U> (_ r: List<U>, _ transform: (Item) -> U) -> List<U> {
    switch self {
    case .none: return r
    case let .cons (car, cdr):
      return cdr.rmapping (List<U>.cons (transform (car), r), transform)
    }
  }

  public func map<U> ( _ transform: (T) -> U) -> List<U> {
    return reverse.rmapping (List<U>.none, transform)
  }
  
  private func rfiltering (_ r: List<Item>, _ includeElement: (Item) -> Bool) -> List<Item> {
    switch self {
    case .none: return r
    case let .cons (car, cdr):
      return cdr.rfiltering (includeElement(car) ? List<Item>.cons (car, r) : r, includeElement)
    }
  }

  public func filter ( _ includeElement: (Item) -> Bool) -> List<T> {
    return reverse.rfiltering (List<Item>.none, includeElement)
  }

  public var reverse : List<T> {
    func reving (_ l: List<T>, _ r:List<T>) -> List<T> {
      switch l {
      case .none: return r
      case let .cons (car, cdr):
        return reving (cdr, List.cons(car, r))
      }
    }
    return reving (self, List<T>.none)
  }
 
  public func partition (_ pred: (T) -> Bool) -> (List<T>, List<T>) {
    func parting (_ lst: List<T>, pos: List<T>, neg: List<T>, pred: (T) -> Bool)
        -> (List<T>, List<T>) {
            switch lst {
            case .none: return (pos, neg)
            case let .cons (car, cdr):
                return (pred (car)
                    ? parting (cdr, pos: List.cons(car, pos), neg: neg, pred: pred)
                    : parting (cdr, pos: pos, neg: List.cons(car, neg), pred: pred))
            }
    }
    return parting (reverse, pos: List<T>(), neg: List<T>(), pred: pred)
  }
    
    
  // MARK: foldl, foldr
    
  public func foldl<S> (_ initial: S, combine: (S, T) -> S) -> S {
    switch self {
    case .none: return initial
    case let .cons (car, cdr):
        return cdr.foldl (combine (initial, car), combine: combine)
    }
  }
  
  public func foldr<S> (_ initial: S, combine: (T, S) -> S) -> S {
    switch self {
    case .none: return initial
    case let .cons (car, cdr):
      return combine (car, cdr.foldr (initial, combine: combine))
    }
  }
  
  // has
  // any
  // all
 
  public func equalToList (_ that: List<T>, pred: (T, T) -> Bool) -> Bool {
    let car1 = self.car
    let car2 = that.car
    
    return (nil == car1 && nil == car2) ||
      (nil != car1 && nil != car2 &&
        pred (car1!, car2!) &&
        self.cdr!.equalToList(that.cdr!, pred: pred))
  }
  
  public func any ( _ predicate: (T) -> Bool) -> Bool {
    switch self {
    case .none: return false
    case let .cons (car, cdr):
      return predicate(car) || cdr.any(predicate)
    }
  }
  
  public func all ( _ predicate: (T) -> Bool) -> Bool {
    switch self {
    case .none: return true
    case let .cons (car, cdr):
      return predicate(car) && cdr.all(predicate)
    }
  }
  
  // Lazy
  public var lazy : LazyList<List<T>> {
    return LazyList(base: self)
  }
}

extension List : ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: T...) {
    self.init(elements: elements)
  }
}


// MARK: List as BagType

extension List : BagType {

  public var isEmpty : Bool {
    switch self {
    case .none: return true
    case .cons: return false
    }
  }
  
  public var count : Int {
    switch self {
    case .none: return 0
    case let .cons (_, cdr):
      return 1 + cdr.count
    }
  }

  public func app ( _ apply: (T) -> ())  {
    switch self {
    case .none: return
    case let .cons (car, cdr):
      apply (car)
      cdr.app (apply)
    }
  }
  
  public func app (_ apply: (T) throws -> ()) rethrows {
    switch self {
    case .none: return
    case let .cons (car, cdr):
      try apply (car)
      try cdr.app (apply)
    }
  }

  public var array : Array<Item> {
    var array = Array<Item>()
    app { array.append($0) }
    return array
  }

  public var list : List<Item> {
    return self
  }
 
}

// MARK: List where T: Equatable
extension List where T : Equatable {
  public func contains (_ item: Item) -> Bool {
    switch self {
    case .none: return false
    case let .cons (car, cdr):
      return item == car || cdr.contains(item)
    }
  }
}

// MARK: List as OrderedBagType

extension List : OrderedBagType {
  public func reduce<Result>(_ initial: Result, combine: (Result, Item) -> Result) -> Result {
    return foldl(initial, combine: combine)
  }
}
