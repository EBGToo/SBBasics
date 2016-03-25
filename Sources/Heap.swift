//
//  Heap.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

// MARK: - Heap Type

///
/// A HeapType stores items according to a 'Priority Heap' discipline based on a ordering defined
/// for `Comparable` items
///
protocol HeapType {
  
  /// Items are `Comparable`
  associatedtype Item : Comparable
  
  /// Return, w/o removing, the extreme element of the heap
  var extreme : Item? { get }

  /// Remove and return the extreme element of the heap
  mutating func extract () -> Item?
  
  /// Insert the provided element into the heap
  mutating func insert (_ item:Item)
  
  /// Remove the provided element from the heap.  If it exists, one and only
  /// one element is removed.
  mutating func remove (_ item: Item)

  /// 
  /// Remove one and only one item, the first one found, where `predicate` is true.  If an item was
  /// removed then `true` is returned, otherwise `false`.
  ///
  /// - parameter predicate: The predicate to determine which item to remove
  ///
  /// - returns: `true` iff removed
  ///
  mutating func removeIf ( _ predicate: (Item) -> Bool) -> Bool
   
  /// Reheapify assuming the comparability of `item` changed.  This can't possibly work if the 
  /// Item's `Equatable` property changed and is now equal to another item's property.  The 
  /// `reheap()` will possibly confuse the two items.  
  /// 
  /// Note that one should not expect this to work... Similar to `Hashable`, a Set, Dictionary will
  /// be 'confused' if the `Hashable` property inexplicably changes.
  /// 
  /// Perhaps need to reheap all matches of 'Item' ... if possible
  ///
  mutating func reheap (_ item: Item)
  
  ///
  /// Reheap one and only one item, the first one found, where `predicate` is true.  Reheap is
  /// used when the item's 'Comparable' property changed - which you ought not do and if you do
  /// change the 'Comparable' property and do not call this function, then the heap property is
  /// destroyed and results will be unpredicatable at best.
  ///
  /// - parameter predicate: The predicate to determine which item to reheap.
  ///
  mutating func reheapIf ( _ predicate: (Item) -> Bool)

  ///
  /// Check if heap contains `Item` based on `predicate`.
  ///
  /// - parameter predicate: The predicate to identify items.
  ///
  func containsIf ( _ predicate: (Item) -> Bool) -> Bool
}

// MARK: - Heap

///
/// A Heap stores items according to a 'Priority Heap' discipline; it is an OrderedBagType
///
public struct Heap <E:Comparable> : HeapType {
  public typealias Item = E
  
  internal var objs : Array<Item>

  private var compare = { (o1:Item, o2:Item) -> Bool in return o1 < o2 }
  
  /// Create a Heap with `items` heapified
  internal init (items: [Item]) {
    // Create an empty heap; add items one-by-one.
    var heap = Heap<Item>()
    for item in items {
      heap.insert (item)
    }
    self.objs = heap.objs
  }
  
  /// Create an empty Heap
  public init () {
    objs = []
  }

  /// Create a Heap with `item`
  public init (item : Item) {
    objs = [item]
  }
  
  // Heap Indices: 0 1 2 3 4 5 6
  //
  // i=0, p=x, l=1, r=2
  // i=1, p=0, l=3, r=4
  // i=2, p=0, l=5, r=6
  // i=3, p=1, l=7, r=8

  private func hp (_ i:Int) -> Int { return (i  - 1) >> 1 }  // parent
  private func hl (_ i:Int) -> Int { return (i << 1)  + 1 }  // left
  private func hr (_ i:Int) -> Int { return (i << 1)  + 2 }  // right
  
  // Protocol HeapType
  
  public var extreme : Item? {
    return objs.first
  }
  
  private mutating func heaping (_ c:Int, _ s:Int) {
    let l = hl (c)
    let r = hr (c)
    var b = c
    
    if l < s && compare (objs[l], objs[c]) { b = l }
    if r < s && compare (objs[r], objs[b]) { b = r }
    
    if b != c {
      objs.swapAt(b, c)
      heaping (b, s)
    }
  }
  
  private mutating func reheaping (_ index: Int) {
    let item = objs.removeLast();
    if index < objs.count {
      objs[index] = item
      heaping (index, objs.count)
    }
  }
  
  public mutating func extract () -> Item? {
    if let extreme = objs.first {
      reheaping (0)
      return extreme
    }
    return nil
  }
  
  public mutating func remove (_ item : Item) {
    if let index = objs.firstIndex (of: item) {
      reheaping (index)
    }
  }

  public mutating func removeIf ( _ predicate: (Item) -> Bool) -> Bool {
    if let index = objs.firstIndex (where: predicate) {
      reheaping (index)
      return true
    }
    return false
  }

  // Can this possibly work if the heap has identical items?  What if the first one found is
  // not the one with the changed comparable?  Than we move/leave the wrong item and ignore the
  // changed item.
  public mutating func reheap (_ item: Item) {
    if let index = objs.firstIndex (of: item) {
      reheaping (index)
      insert (item)
    }
  }
  
  public mutating func reheapIf( _ predicate: (Item) -> Bool) {
    if let index = objs.firstIndex(where: predicate) {
      let item = objs[index]
      reheaping(index)
      insert (item)
    }
  }
  
  public func containsIf ( _ predicate: (Item) -> Bool) -> Bool {
    return nil != objs.firstIndex(where: predicate)
  }
  
  private mutating func bubbling (_ c:Int, _ item: Item) {
    let p = hp(c)
    if c > 0 && compare(item, objs[p]) {
      objs[c] = objs[p]
      bubbling (p, item)
    }
    else { objs[c] = item }
  }
  
  public mutating func insert (_ item : Item) {
    objs.append(item)
    bubbling (objs.count - 1, item)
  }
  
  public func map<U> (_ transform : (Item) -> U) -> Heap<U> {
    var heap = Heap<U>()
    for item in objs {
      heap.insert(transform (item))
    }
    return heap
  }
}

// MARK: Heap as ArrayLiteralConvertible

extension Heap : ExpressibleByArrayLiteral {
  public init (arrayLiteral elements: Item...) { self.init(items: elements) }
}

// MARK: Heap as OrderedBagType

extension Heap : OrderedBagType {
  
  public var count : Int {
    return objs.count
  }
  
  public var isEmpty : Bool {
    return objs.isEmpty
  }
  
  public func app ( _ apply: (Item) -> Void) -> Void {
    var temp = self
    while let item = temp.extract() { apply(item) }
  }
  
  public func app (_ apply: (Item) throws  -> Void) rethrows -> Void {
    var temp = self
    while let item = temp.extract() { try apply (item) }
  }
  
  public func filter ( _ includeElement: (Item) -> Bool) -> Heap<Item> {
    var heap = Heap<Item>()
    for item in objs.filter(includeElement) {
      heap.insert(item)
    }
    return heap
  }
  
  public var array : [Item] {
    var result = Array<Item>()
    app { result.append($0) }
    return result
  }
  
  // Surely avoid the default BagType implementation using `app()`
  public func contains (_ item: Item) -> Bool {
    return objs.contains(item)
  }
}
