//
//  HeapTest.swift
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

public class Pair : Comparable {
  var car : String
  var cdr : Int
  
  init (car : String, cdr : Int) {
    self.car = car
    self.cdr = cdr
  }
}

public func == (lhs: Pair, rhs: Pair) -> Bool { return lhs.cdr == rhs.cdr }
public func  < (lhs: Pair, rhs: Pair) -> Bool { return lhs.cdr  <  rhs.cdr }

class HeapTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testHeap() {
    var h1 : Heap<Int> = Heap()
    
    XCTAssert(h1.isEmpty, "empty")
    XCTAssert(0 == h1.count, "0 == count")
    
    h1.insert(10)
    XCTAssertFalse(h1.isEmpty, "!empty")
    XCTAssert(1 == h1.count, "1 == count")
    XCTAssertEqual(10, h1.extreme!, "0 == extreme")
    
    h1.insert(5)
    XCTAssert(2 == h1.count, "2 == count")
    XCTAssertEqual(5, h1.extreme!, "5 == extreme")
    
    h1.insert(0)
    XCTAssert(3 == h1.count, "3 == count")
    XCTAssertEqual(0, h1.extreme!, "10 == extreme")
    
    h1.insert(8)
    XCTAssert(4 == h1.count, "4 == count")
    XCTAssertEqual(0, h1.extreme!, "10 == extreme")
    
    XCTAssertEqual(0, h1.extract()!, "10 == extract")
    XCTAssert(3 == h1.count, "3 == count")
    XCTAssertEqual(5, h1.extreme!, "8 == extreme")
    XCTAssertEqual(5, h1.extract()!, "8 == extreme")
  }
  
  func testHeapLiteral () {
    var h1 : Heap<Int> = [0, 10, 20]
    
    XCTAssertEqual(3, h1.count, "3 == count")
    XCTAssertEqual(0, h1.extreme!, "20 == extreme")
    
    h1 = Heap()
    XCTAssertNil(h1.extreme, "nil == extreme")
    XCTAssertNil(h1.extract(), "nil == extract()")
    
    h1 = Heap (arrayLiteral: 15, 25, 5)
    XCTAssertEqual( 5, h1.extract()!, "extract: 25")
    XCTAssertEqual(15, h1.extract()!, "extract: 15")
    XCTAssertEqual(25, h1.extract()!, "extract:  5")
    
    XCTAssertTrue(h1.isEmpty, "empty")
  }
  
  func testHeapRemove () {
    var h1 : Heap<Int> = [0, 15, 10, 20]
    
    XCTAssertEqual(4, h1.count, "3 == count")
    XCTAssertEqual(0, h1.extreme!, "20 == extreme")
    
    h1.remove (-10)
    XCTAssertEqual(4, h1.count, "4 == count")
    XCTAssertEqual(0, h1.extreme!, "20 == extreme")
    
    h1.remove (10)
    XCTAssertEqual(3, h1.count, "3 == count")
    XCTAssertEqual( 0, h1.extract()!, " 0 == extreme")
    XCTAssertEqual(15, h1.extract()!, "15 == extreme")
    XCTAssertEqual(20, h1.extract()!, "00 == extreme")
    XCTAssertNil(h1.extreme, " 0 == extreme")
    
    h1.remove (0)
    XCTAssertEqual(0, h1.count, "3 == count")
    XCTAssertNil(h1.extreme, " 0 == extreme")
    
  }
  
  
  func testHeapReheap () {
    var h = Heap<Pair>()
    
    let p = Pair(car: "b", cdr: 5)
    
    h.insert(Pair(car: "a", cdr: 0))
    h.insert(p)
    h.insert(Pair(car: "c", cdr: 10))
    h.insert(Pair(car: "d", cdr: 20))
    
    p.cdr = 15
    h.reheap(p)
    
    XCTAssertEqual("a", h.extract()!.car, " 0 == extreme")
    XCTAssertEqual("c", h.extract()!.car, "10 == extreme")
    XCTAssertEqual("b", h.extract()!.car, "15 == extreme")
    XCTAssertEqual("d", h.extract()!.car, "20 == extreme")
    
    // 2
    
    h.insert(Pair(car: "a", cdr: 0))
    h.insert(p)
    h.insert(Pair(car: "c", cdr: 10))
    h.insert(Pair(car: "d", cdr: 20))
    
    p.cdr = 25
    h.reheap(p)
    
    XCTAssertEqual("a", h.extract()!.car, " 0 == extreme")
    XCTAssertEqual("c", h.extract()!.car, "10 == extreme")
    XCTAssertEqual("d", h.extract()!.car, "20 == extreme")
    XCTAssertEqual("b", h.extract()!.car, "25 == extreme")
    
    // 3
    
    h.insert(Pair(car: "a", cdr: 0))
    h.insert(p)
    h.insert(Pair(car: "c", cdr: 10))
    h.insert(Pair(car: "d", cdr: 20))
    
    
    p.cdr = -5
    h.reheap(p)
    
    XCTAssertEqual("b", h.extract()!.car, "-5 == extreme")
    XCTAssertEqual("a", h.extract()!.car, " 0 == extreme")
    XCTAssertEqual("c", h.extract()!.car, "10 == extreme")
    XCTAssertEqual("d", h.extract()!.car, "20 == extreme")
    
  }
  
  func testHeapGenerate () {
    let h1 : Heap<Int> = [0, 15, 10, 20]
    var r1 : List<Int> = [0, 10, 15, 20]
    
    h1.app {
      XCTAssertEqual($0, r1.car)
      r1 = r1.cdr!
    }
    
    XCTAssertEqual(0, h1.extreme, "0 == extreme after generate")
    
    var r2 : List<Int> = [0, 10, 15, 20]
    
    h1.app {
      XCTAssertEqual($0, r2.car)
      r2 = r2.cdr!
    }
  }
  
  func testHeapMultiple () {
    let h1 : Heap<Int> = [0, 0, 20, 20, 10, 10]
    var r1 : List<Int> = [0, 0, 10, 10, 20, 20]
    
    h1.app {
      XCTAssertEqual($0, r1.car)
      r1 = r1.cdr!
    }
  }
  
  
  func XtestPerformanceExample() {
    self.measure() {
    }
  }
}
