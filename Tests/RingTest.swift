//
//  RingTest.swift
//  SBBasics
//
//  Created by Ed Gamble on 12/9/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import XCTest
@testable import SBBasics

class RingTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testRing() {
    var r1 = Ring<Int>(capacity: 3)
    XCTAssertTrue(r1.isEmpty)
    XCTAssertEqual(r1.capacity, 3)
    XCTAssertNil(r1.look)
    XCTAssertNil(r1.get())
    
    r1.put(10)
    XCTAssertFalse(r1.isEmpty)
    XCTAssertEqual(r1.count, 1)
    XCTAssertEqual(r1.look, 10)

    XCTAssertEqual(r1.get(), 10)
    XCTAssertTrue(r1.isEmpty)
    XCTAssertEqual(r1.count, 0)

    r1.put(10)
    r1.put(20)
    r1.put(30)
    
    XCTAssertFalse(r1.isEmpty)
    XCTAssertEqual(r1.count, 3)
    
    r1.put(40)
    XCTAssertEqual(r1.count, 3)
    XCTAssertEqual(r1.get(), 20)
    XCTAssertEqual(r1.get(), 30)

    r1.put(50)
    XCTAssertEqual(r1.array, [40, 50])
  }
  
  func testRingFilter () {
    var r1 = Ring<Int>(capacity: 3)
    r1.put(1)
    r1.put(2)
    r1.put(3)
    
    var r2 = r1.filter { 0 != $0 % 2 }
    
    XCTAssertEqual(r2.get(), 1)
    XCTAssertEqual(r2.get(), 3)
  }
  
  func testRingArray () {
    var r1 = Ring<Int>(capacity: 3)
    r1.put(1)
    r1.put(2)
    r1.put(3)
    
    let a1 = r1.array
    let ax = [1, 2, 3]

    XCTAssertTrue(a1.elementsEqual(ax))
  }
  
  func testRingList () {
    var r1 = Ring<Int>(capacity: 3)
    r1.put(1)
    r1.put(2)
    r1.put(3)
    
    let l1 = r1.list
    let lx : List<Int> = [1, 2, 3]
    
    XCTAssertTrue(l1.equalToList(lx, pred: ==))
  }
  
  func testRingReduce () {
    var r1 = Ring<Int>(capacity: 3)
    r1.put(1)
    r1.put(2)
    r1.put(3)

    XCTAssertEqual(r1.reduce(10, combine: +), 16)
  }
  
  func testPerformanceExample() {
    self.measure {
    }
  }
}
