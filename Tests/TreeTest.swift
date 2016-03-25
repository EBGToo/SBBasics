//
//  TreeTest.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import XCTest
@testable import SBBasics
import SBCommons

struct BoxX<Item:Comparable, Value> : Comparable {
  let item  : Item
  let value : Value
}

func == <Item: Comparable, Value> (lhs:BoxX<Item, Value>, rhs:BoxX<Item, Value>) -> Bool {
  return lhs.item == rhs.item
}

func < <Item: Comparable, Value> (lhs:BoxX<Item, Value>, rhs:BoxX<Item, Value>) -> Bool {
  return lhs.item < rhs.item
}

class TreeTest: XCTestCase {
  let perfCount = 1000
  var perfArray = Array<Int>(repeating: 0, count: 1000)

  
  override func setUp() {
    super.setUp()
    for i in 0..<perfCount { perfArray[i] = Int(arc4random()) % perfCount }
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: Tree
  
  func testTree() {
    let t1 = Tree<String>(item: "+")
    
    XCTAssert(t1.contains("+"), "contain root")
    
    // (+ (* 5 2) 3)
    let t2 = Tree<String>(item: "+", kids:
      [Tree<String>(item: "*", items: ["5", "2"]),
        Tree<String>(item: "3")])
    
    XCTAssertEqual(t2.count, 5)
    XCTAssertEqual(t2.degree, 2)
    XCTAssertEqual(t2.height, 2)
    
    XCTAssertEqual(t2.depth("+", pred: ==), 0)
    XCTAssertEqual(t2.depth("*", pred: ==), 1)
    XCTAssertEqual(t2.depth("3", pred: ==), 1)
    XCTAssertEqual(t2.depth("5", pred: ==), 2)
    XCTAssertEqual(t2.depth("2", pred: ==), 2)
    
    XCTAssertFalse(t2.isKidless)
    
    XCTAssertNil(t2.parent("+", pred: ==))
    XCTAssertEqual(t2.parent("3", pred: ==)!.item, "+")
    XCTAssertEqual(t2.parent("*", pred: ==)!.item, "+")
    XCTAssertEqual(t2.parent("5", pred: ==)!.item, "*")
    XCTAssertEqual(t2.parent("2", pred: ==)!.item, "*")

    XCTAssertEqual(t2.parent("*", pred: ==)!.degree, 2)
  }
  
  func testTreeWalkDepth () {
    let t = Tree<String>(item: "+", kids:
      [Tree<String>(item: "*", items: ["5", "2"]),
        Tree<String>(item: "3")])
    
    var s1 = ""
    var s2 = ""
    var s3 = ""
    t.walkByDepth(preOrder: { s1 += ($0 + " ") },
      inOrder: { s2 += ($0 + " ") },
      postOrder: { s3 += ($0 + " ") })
    
    XCTAssertEqual(s1, "+ * 5 2 3 ")
    XCTAssertEqual(s2, "* + ")
    XCTAssertEqual(s3, "5 2 * 3 + ")
  }
  
  func testTreeWalkBreadth () {
    let t = Tree<String>(item: "+", kids:
      [Tree<String>(item: "*", items: ["5", "2"]),
        Tree<String>(item: "3")])
    
    var s1 = ""
    var s3 = ""
    t.walkByBreadth(preOrder: { s1 += ($0 + " ") }, postOrder: { s3 += ($0 + " ") })
    
    XCTAssertEqual(s1, "+ * 3 5 2 ")
    XCTAssertEqual(s3, "2 5 3 * + ")
    
    let t8 = Tree<Int>(item: 8)
    let t7 = Tree<Int>(item: 7, items: [11, 12])
    let t6 = Tree<Int>(item: 6)
    let t5 = Tree<Int>(item: 5, items: [9, 10])
    let t4 = Tree<Int>(item: 4, kids: [t7, t8])
    let t3 = Tree<Int>(item: 3)
    let t2 = Tree<Int>(item: 2, kids: [t5, t6])
    
    let t1 = Tree<Int>(item: 1, kids: [t2, t3, t4])

    var g1 = [1,2,3,4,5,6,7,8,9,10,11,12].makeIterator()
    t1.walkByBreadth { XCTAssertEqual($0, g1.next()) }
  }
  
  // MARK: Binary Tree
  
  func testBinaryTree () {
    let t = BinaryTree (5)
    
    XCTAssertEqual(t.item, 5)
    XCTAssertTrue(t.kids.isEmpty)
    XCTAssertTrue(t.isKidless)
    XCTAssertEqual(t.degree, 0)
    XCTAssertEqual(t.count, 1)
    XCTAssertEqual(t.height, 0)

    XCTAssertTrue(t.contains(5))
    XCTAssertFalse(t.contains(0))
    XCTAssertFalse(t.contains(10))
    
    XCTAssertEqual(t.depth(5), 0)
    XCTAssertNil(t.depth(10))
    XCTAssertNil(t.depth(0))
    
    XCTAssertNil(t.parent(5))
    XCTAssertNil(t.parent(0))
    
    XCTAssertEqual(t.array, [5])
  }
  
  func testBinaryTreeLiteral () {
    let t : BinaryTree<Int> = [0, 10, 5, 25, 15, 20, 30]
    
    XCTAssertEqual(t.minimum.item, 0)
    XCTAssertEqual(t.maximum.item, 30)
    
    XCTAssertEqual(t.degree, 2)
    XCTAssertEqual(t.depth(t.item), 0)

    var g = [0, 5, 10, 15, 20, 25, 30].makeIterator();
    t.walkByDepth { XCTAssertEqual($0, g.next()) }
    
    g = [0, 10].makeIterator()
    BinaryTree<Int>(items: [0, 10]).walkByDepth { XCTAssertEqual($0, g.next()) }

    g = [0, 5, 10, 15].makeIterator()
    BinaryTree<Int>(items: [15, 10, 0, 5]).walkByDepth { XCTAssertEqual($0, g.next()) }
    
    g = [0, 5, 10, 15, 20].makeIterator()
    BinaryTree<Int>(items: [15, 20, 10, 0, 5]).walkByDepth { XCTAssertEqual($0, g.next()) }
    
  }

  func testBinaryTreeDelete () {
    var t : BinaryTree<Int> = [0, 5, 10]
    var g = [0].makeIterator()
    
    t.delete(0)
    g = [5, 10].makeIterator()
    t.walkByDepth { XCTAssertEqual($0, g.next()) }
    
    t.delete(10)
    g = [5].makeIterator()
    t.walkByDepth { XCTAssertEqual($0, g.next()) }
    
    t.delete(5)
    XCTAssertTrue(t.count == 0)

    t = BinaryTree<Int>(items: [0, 5, 10, 15, 20])
    g = [0, 5, 10, 15, 20].makeIterator()
    t.walkByDepth { XCTAssertEqual($0, g.next()) }

    t.delete(10)
    g = [0, 5, 15, 20].makeIterator()
    t.walkByDepth { XCTAssertEqual($0, g.next()) }
    
    t.delete(0)
    g = [5, 15, 20].makeIterator()
    t.walkByDepth { XCTAssertEqual($0, g.next()) }
    
    t.delete(15)
    g = [5, 20].makeIterator()
    t.walkByDepth { XCTAssertEqual($0, g.next()) }
    
    t.delete(5)
    g = [20].makeIterator()
    t.walkByDepth { XCTAssertEqual($0, g.next()) }
    
    t.delete(20)
    XCTAssertTrue(t.count == 0)
    }
  
  func testBinaryTreeHoldingBox () {
    var t = BinaryTree(BoxX(item: 5, value: "five"))
    
    t.insert(BoxX(item: 3, value: "three"))
    t.insert(BoxX(item: 7, value: "seven"))
    t.insert(BoxX(item: 6, value: "six"))
    
    var g = ["three", "five", "six", "seven"].makeIterator()
    t.walkByDepth { XCTAssertEqual($0.value, g.next()) }
  }
  
  func testBinaryTreeX () {
    var ty = BinaryTree<Int>()
    let n = 10
    for _ in 0..<n {
      ty.insert (Int(arc4random()) % n)
    }
    _ = ty.count
    _ = ty.left?.height
    _ = ty.right?.height
    
    var tz = BinaryTree<Int>()
    let m = 10
    for _ in 0..<m {
      tz.insert (Int(arc4random()) % m)
    }
    _ = tz.count
    _ = tz.left?.height
    _ = tz.right?.height
  }
  
  func testBinaryTreeSuccessor () {
    let t : BinaryTree<Int> = [0, 10, 5, 15, -5, 20, -10]
    
    XCTAssertNil(t.successor(20))
    XCTAssertEqual(t.successor(15)?.item, 20)
    XCTAssertEqual(t.successor(10)?.item, 15)
    XCTAssertEqual(t.successor(5)?.item, 10)
    XCTAssertEqual(t.successor(0)?.item,5)
    XCTAssertEqual(t.successor(-5)?.item,0)
    XCTAssertEqual(t.successor(-10)?.item,-5)

  }
  
  func testBinaryTreePrede () {
    let t : BinaryTree<Int> = [0, 10, 5, 15, -5, 20, -10]
    
    XCTAssertNil(t.predecessor(-10))
    XCTAssertEqual(t.predecessor(-5)?.item, -10)
    XCTAssertEqual(t.predecessor(0)?.item, -5)
    XCTAssertEqual(t.predecessor(5)?.item, 0)
    XCTAssertEqual(t.predecessor(10)?.item, 5)
    XCTAssertEqual(t.predecessor(15)?.item, 10)
    XCTAssertEqual(t.predecessor(20)?.item, 15)
  }
 
  func testPerformanceOneByOne() {
    self.measure() {
      var t = BinaryTree<Int>()
      for i in 0..<self.perfCount { t.insert(self.perfArray[i]) }
    }
  }
  
  func testPerformanceAtOnce () {
    self.measure {
      var _ = BinaryTree<Int>(items: self.perfArray)
    }
    
  }
}
