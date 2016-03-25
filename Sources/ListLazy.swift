//
//  ListLazy.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

// MARK: Lazy List Type

///
/// A LazyListType is a ListBaseType for lazy lists
///
public protocol LazyListType : ListBaseType {

  ///
  associatedtype Elements : ListBaseType //= Self
  
  ///
  var base : Elements { get }
  
  /// 'Force' LazyList, return as a list
  var list : List<Self.Item> { get }
}

///
/// A LazyListType extension to ...
///
extension LazyListType {
  func filter(_ predicate: @escaping (Self.Item) -> Bool) -> LazyFilterList<Self> {
    return LazyFilterList (base : self, filter : predicate)
  }
  
  func map<U>(_ transform: @escaping (Self.Item) -> U) -> LazyMapList<Self, U> {
    return LazyMapList (base : self, transform: transform)
  }
  
  func drop(_ n:Int) -> LazyDropList<Self> {
    return LazyDropList (base: self, count: n)
  }
  
  func take(_ n:Int) -> LazyTakeList<Self> {
    return LazyTakeList (base: self, count: n)
  }
  
//  public func reverse() -> LazyList<Elements> {
//    return LazyList(base: base.reverse())
  //  }
  
  func app ( _ apply: (Item) -> ()) {
    var list = self
    while let elt = list.car {
      apply (elt)
      list = list.cdr!
    }
  }
  
  public var list : List<Item> {
    var result = List<Item>.none
    app { result = List<Item>($0, result) }
    return result.reverse
  }
}

//
//
//
public struct LazyList<Base : ListBaseType> : LazyListType, ListBaseType {
  public let base   : Base
  
  public var car : Base.Item? {
    return base.car
  }
  
  public var cdr : LazyList<Base>? {
    return base.cdr.map {
      return LazyList<Base>(base: $0)
    }
  }
  
}

//
//
//
struct LazyMapList<Base : ListBaseType, U> : LazyListType {
  typealias Elements = Base
  
  let base : Base
  internal let transform : (Base.Item) -> U
  
  var car : U? {
    return base.car.map(transform)
  }
  
  var cdr : LazyMapList<Base, U>? {
    return base.cdr.map {
      return LazyMapList (base: $0, transform: transform)
    }
  }
}

//
//
//
struct LazyFilterList<Base : ListBaseType> : LazyListType {
  //typealias Elements = Base
  
  var base   : Base
  private let filter : (Base.Item) -> Bool
  
  // Return the next element from base that satisfies filter.  Exercise caution
  // that repeated calls *will not* reapply filter
  private let next : () -> Base
  
  var car : Base.Item? {
    return next().car
  }
  
  var cdr : LazyFilterList<Base>? {
    return next().cdr.map {
      LazyFilterList(base: $0, filter:filter)
    }
  }
  
  init (base:Base, filter: @escaping (Base.Item) -> Bool) {
    self.base = base
    self.filter = filter
    
    // We'll build a lexical environment containing a variable pointing to
    // the first .Cons of base where filter is true.  We'll call that variable 'next'
    
    // This is producing a 'mutating' LazyFilterList - we don't actually want that.
    
    self.next = {
      var next :Base!
      return {
        // If we've assigned next previously, then simply return it
        if nil != next { return next }
        else {
          // Walk next until a) filter matches or b) next is empty
          next = base
          while !(next.car.map(filter) ?? true) {
            next = next.cdr!
          }
          //          for (next = base; !(next.car.map(filter) ?? true); next = next.cdr!) {}
          // Return the .Cons
          return next
        }
      }
      }()
  }
}

//
//
//
struct LazyDropList<Base : ListBaseType> : LazyListType {
  //typealias Elements = Base
  
  let base   : Base
  private let next : () -> Base
  
  var car : Base.Item? {
    return next().car
  }
  
  var cdr : LazyDropList<Base>? {
    return next().cdr.map {
      LazyDropList (base: $0, count: 0)
    }
  }
  
  init (base:Base, count: Int) {
    var count = count

    self.base = base
    
    self.next = 0 == count
      ? { return base }
      : {
        var next :Base!
        return {
          // If we've assigned next previously, then simply return it
          if nil != next { return next }
          else {
            // Walk next until a) filter matches or b) next is empty
            next = base
            while count > 0 && nil != next.car {
              //for (next = base; count > 0 && nil != next.car; next = next.cdr!) {
              count -= 1
              next = next.cdr!
            }
            // Return the .Cons
            return next
          }
        }
        }()
  }
}

//
//
//
struct LazyTakeList<Base : ListBaseType> : LazyListType {
  
  let base   : Base
  let count : Int
  
  var car : Base.Item? {
    return count == 0 ? nil : base.car
  }
  
  var cdr : LazyTakeList<Base>? {
    return count == 0 ? nil : base.cdr.map {
      LazyTakeList (base: $0, count: count == 0 ? 0 : count - 1)
    }
  }
  
  init (base:Base, count: Int) {
    self.base = base
    self.count = count
  }
}
