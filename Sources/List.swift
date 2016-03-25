//
//  List.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Opus Logica Inc. All rights reserved.
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
  func partition (pred: (Item) -> Bool) -> (List<Item>, List<Item>)

  ///
  /// - parameter initial:
  /// - parameter combine:
  /// - returns:
  ///
  func foldl<S> (initial: S, @noescape combine: (S, Item) -> S) -> S

  ///
  ///
  
  ///
  /// - parameter initial:
  /// - parameter combine:
  /// - returns:
  ///
  func foldr<S> (initial: S, combine: (Item, S) -> S) -> S

  ///  Check if `any` Item satisfies `predicate`
  func any (@noescape predicate: (Item) -> Bool) -> Bool

  /// Check if `all` Items satisfy `predicate`
  func all (@noescape predicate: (Item) -> Bool) -> Bool

  /// Check if `self` and `that` have idential Items compared with `pred`
  func equalToList (that: List<Item>, pred: (Item, Item) -> Bool) -> Bool

  /// A list with items reversed
  var reverse : Self { get }
  
  /// The first item or Optional.None
  var first : Item? { get }
  
  /// The last item or Optional.None
  var last : Item? { get }

  /// A list with the items that satisfy `includeElement`
  func filter (@noescape includeElement: (Item) -> Bool) -> List<Item>
  
  /// A list with `transform` applied to each item
  func map<U> (@noescape transform: (Item) -> U) -> List<U>

  /// A Lazy list
  var lazy : LazyList<List<Item>> { get }
}

// MARK: List


/// A List
public enum List<T> : ListType {
  case Nil
  indirect case Cons (T, List<T>)
  
  public typealias Item = T
  
  public var car : T? {
    switch self {
    case .Nil: return nil
    case .Cons (let car, _): return car
    }
  }
  
  public var cdr : List<T>? {
    switch self {
    case .Nil: return nil
    case .Cons (_, let cdr): return cdr
    }
  }
  
  
  // MARK: Init
  
  public init (elements: [T]) {
    self = Nil
    for elt in elements.reverse() {
      self = Cons(elt, self)
    }
  }
  
  public init () {
    self = Nil
  }
  
  public init (_ car: T) {
    self = Cons (car, Nil)
  }
  
  public init (_ car: T, _ cdr: List<T>) {
    self = Cons (car, cdr)
  }
  
  public var first : T? {
    switch self {
    case .Nil: return nil
    case let .Cons (car, _): return car
    }
  }
  
  public var last : T? {
    switch self {
    case .Nil: return nil
    case let .Cons (car, .Nil): return car
    case let .Cons (_, cdr):
      return cdr.last
    }
  }
  
  public subscript(n:Int) -> T? {
    switch self {
    case .Nil: return nil
    case let .Cons (car, cdr):
      return (0 == n ? car : cdr[n - 1])
    }
  }

  // MARK: Map, Filter, Reverse, Partition -> List
  
  private func rmapping<U> (r: List<U>, @noescape _ transform: (Item) -> U) -> List<U> {
    switch self {
    case .Nil: return r
    case let .Cons (car, cdr):
      return cdr.rmapping (List<U>.Cons (transform (car), r), transform)
    }
  }

  public func map<U> (@noescape transform: (T) -> U) -> List<U> {
    return reverse.rmapping (List<U>.Nil, transform)
  }
  
  private func rfiltering (r: List<Item>, @noescape _ includeElement: (Item) -> Bool) -> List<Item> {
    switch self {
    case .Nil: return r
    case let .Cons (car, cdr):
      return cdr.rfiltering (includeElement(car) ? List<Item>.Cons (car, r) : r, includeElement)
    }
  }

  public func filter (@noescape includeElement: (Item) -> Bool) -> List<T> {
    return reverse.rfiltering (List<Item>.Nil, includeElement)
  }

  public var reverse : List<T> {
    func reving (l: List<T>, _ r:List<T>) -> List<T> {
      switch l {
      case .Nil: return r
      case let .Cons (car, cdr):
        return reving (cdr, List.Cons(car, r))
      }
    }
    return reving (self, List<T>.Nil)
  }
 
  public func partition (pred: (T) -> Bool) -> (List<T>, List<T>) {
    func parting (lst: List<T>, pos: List<T>, neg: List<T>, pred: (T) -> Bool)
        -> (List<T>, List<T>) {
            switch lst {
            case .Nil: return (pos, neg)
            case let .Cons (car, cdr):
                return (pred (car)
                    ? parting (cdr, pos: List.Cons(car, pos), neg: neg, pred: pred)
                    : parting (cdr, pos: pos, neg: List.Cons(car, neg), pred: pred))
            }
    }
    return parting (reverse, pos: List<T>(), neg: List<T>(), pred: pred)
  }
    
    
  // MARK: foldl, foldr
    
  public func foldl<S> (initial: S, @noescape combine: (S, T) -> S) -> S {
    switch self {
    case .Nil: return initial
    case let .Cons (car, cdr):
        return cdr.foldl (combine (initial, car), combine: combine)
    }
  }
  
  public func foldr<S> (initial: S, combine: (T, S) -> S) -> S {
    switch self {
    case .Nil: return initial
    case let .Cons (car, cdr):
      return combine (car, cdr.foldr (initial, combine: combine))
    }
  }
  
  // has
  // any
  // all
 
  public func equalToList (that: List<T>, pred: (T, T) -> Bool) -> Bool {
    let car1 = self.car
    let car2 = that.car
    
    return (nil == car1 && nil == car2) ||
      (nil != car1 && nil != car2 &&
        pred (car1!, car2!) &&
        self.cdr!.equalToList(that.cdr!, pred: pred))
  }
  
  public func any (@noescape predicate: (T) -> Bool) -> Bool {
    switch self {
    case .Nil: return false
    case let .Cons (car, cdr):
      return predicate(car) || cdr.any(predicate)
    }
  }
  
  public func all (@noescape predicate: (T) -> Bool) -> Bool {
    switch self {
    case .Nil: return true
    case let .Cons (car, cdr):
      return predicate(car) && cdr.all(predicate)
    }
  }
  
  // Lazy
  public var lazy : LazyList<List<T>> {
    return LazyList(base: self)
  }
}

extension List : ArrayLiteralConvertible {
  public init(arrayLiteral elements: T...) {
    self.init(elements: elements)
  }
}


// MARK: List as BagType

extension List : BagType {

  public var isEmpty : Bool {
    switch self {
    case .Nil: return true
    case .Cons: return false
    }
  }
  
  public var count : Int {
    switch self {
    case .Nil: return 0
    case let .Cons (_, cdr):
      return 1 + cdr.count
    }
  }

  public func app (@noescape apply: (T) -> ())  {
    switch self {
    case .Nil: return
    case let .Cons (car, cdr):
      apply (car)
      cdr.app (apply)
    }
  }
  
  public func app (@noescape apply: (T) throws -> ()) rethrows {
    switch self {
    case .Nil: return
    case let .Cons (car, cdr):
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
  public func contains (item: Item) -> Bool {
    switch self {
    case .Nil: return false
    case let .Cons (car, cdr):
      return item == car || cdr.contains(item)
    }
  }
}

// MARK: List as OrderedBagType

extension List : OrderedBagType {
  public func reduce<Result>(initial: Result, @noescape combine: (Result, Item) -> Result) -> Result {
    return foldl(initial, combine: combine)
  }
}
