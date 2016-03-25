//
//  Ring.swift
//  SBBasics
//
//  Created by Ed Gamble on 12/8/15.
//  Copyright © 2015 Opus Logica Inc. All rights reserved.
//

///
/// A Ring is a buffer of arbitrary Items.
///
///
public protocol RingType {
  associatedtype Item

  mutating func put (item: Item)
  mutating func get () -> Item?
  var look : Item? { get }
}

///
/// A Ring is a buffer of arbitrary Items
///
///
public struct Ring<E> : RingType {
  
  public typealias Item = E
  
  let capacity : Int
  
  var head : Int = 0
  var tail : Int = 0
  
  private var items = Array<Item>()
  
  public init (capacity: Int) {
    self.capacity = max (capacity, 1)
    self.items = Array<Item>()
  }
  
  public mutating func put (item: Item) {
    if items.count < capacity {
      items.append(item)
    }
    else {
      items[tail % capacity] = item
    }

    if tail == Int.max {
      tail %= capacity
      head %= capacity
    }
    
    tail += 1
    
    if tail > head + capacity {
      head += 1
    }
  }
  
  public mutating func get () -> Item? {
    guard tail != head else { return nil }

    let item = items[head % capacity]
    head += 1
    return item
  }
  
  public var look : Item? {
    return tail != head ? items[head] : nil
  }
}


extension Ring : BagType {
  public var count : Int {
    return tail - head
  }
  
  public var isEmpty : Bool {
    return head == tail
  }
  
  public func app (@noescape apply: (Item) throws -> Void) rethrows -> Void {
    for index in head ..< tail {
      try apply (items[index % capacity])
    }
  }
  
  public func filter (@noescape includeElement: (Item) -> Bool) -> Ring<Item> {
    let array  = self.array.filter(includeElement)
    var result = Ring<Item>(capacity: array.count)
    array.forEach { result.put($0) }
    return result
  }
  
  public var array : [Item] {
    var result = [Item]()
    app { result.append($0) }
    return result
  }
  
  public var list : List<Item> {
    var result = List<Item>()
    app { result = List.Cons($0, result) }
    return result.reverse
  }
}


extension Ring : OrderedBagType {
  public func reduce<Result>(initial: Result, @noescape combine: (Result, E) -> Result) -> Result {
    var result = initial
    app { result = combine (result, $0) }
    return result
  }
}

