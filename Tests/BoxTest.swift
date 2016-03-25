//
//  BoxTest.swift
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

class BoxTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testBox() {
    let c1 : Box<String> = Box(item:"a")
    let c2 : Box<String> = Box(item:"b")
    
    XCTAssertEqual(c1.item, "a", "Missed 'a'")
    XCTAssertEqual(c2.item, "b", "Missed 'b'")
    
    XCTAssertFalse(c1===c2, "missed c1!==c2")
  }
  
  
  func testBinaryBox () {
    let c1 : BinaryBox<Int> = BinaryBox(item:1)
    
    XCTAssertEqual(c1.degree, 0, "degree 0")
    XCTAssertEqual(c1.depth,  0, "depth 0")
    XCTAssertEqual(c1.count,   0, "size 0")
    XCTAssertEqual(c1.height, 0, "height 0")
    
    //XCTAssertEqual(c1.origin, c1, "origin me")
    
    let c2 : BinaryBox<Int> = BinaryBox(item:2)
    let c3 : BinaryBox<Int> = BinaryBox(item:3)
    
    c1.addLeft(c2)
    c1.addRight(c3)
    
    XCTAssertEqual(c1.degree, 2, "degree 2")
    XCTAssertEqual(c1.depth,  0, "depth 0")
    XCTAssertEqual(c1.count,   2, "size 2")
    XCTAssertEqual(c1.height, 1, "height 1")
    
    XCTAssertEqual(c2.degree, 0, "degree 2")
    XCTAssertEqual(c2.depth,  1, "depth 0")
    XCTAssertEqual(c2.count,   0, "size 2")
    XCTAssertEqual(c2.height, 0, "height 1")
    
    let c4 = BinaryBox(item: 4)
    c2.addLeft(c4)
    
    XCTAssertEqual(c1.degree, 2, "degree 2")
    XCTAssertEqual(c1.depth,  0, "depth 0")
    XCTAssertEqual(c1.count,   3, "size 3")
    XCTAssertEqual(c1.height, 2, "height 1")
    
    XCTAssertEqual(c2.degree, 1, "degree 1")
    XCTAssertEqual(c2.depth,  1, "depth 0")
    XCTAssertEqual(c2.count,   1, "size 1")
    XCTAssertEqual(c2.height, 1, "height 1")
    
    XCTAssertEqual(c4.degree, 0, "degree 0")
    XCTAssertEqual(c4.depth,  2, "depth 2")
    XCTAssertEqual(c4.count,   0, "size 0")
    XCTAssertEqual(c4.height, 0, "height 0")
    
  }
  
  func testBoxedTree () {
    typealias Me = BoxedTree<String>
    
    let c1 = Me(item: "1")
    
    let c11 = Me(item: "11")
    let c12 = Me(item: "12")
    
    let c111 = Me (item: "111")
    let c112 = Me (item: "112")
    
    c1.addKid (c11)
    c1.addKid (c12)
    
    c11.addKid (c111)
    c11.addKid (c112)
    
    var c1ca = c1.kids 
    
    XCTAssertTrue(c1ca.contains(c11), "missed c11")
    XCTAssertTrue(c1ca.contains(c12), "missed c12")
    
    let c11ca = c11.kids 
    
    XCTAssertTrue(c11ca.contains(c111), "missed c111")
    XCTAssertTrue(c11ca.contains(c112), "missed c112")
    
    c1ca = c1.descendents 
    
    XCTAssertTrue(c1ca.contains(c11),  "missed c11")
    XCTAssertTrue(c1ca.contains(c12),  "missed c12")
    XCTAssertTrue(c1ca.contains(c111), "missed c111")
    XCTAssertTrue(c1ca.contains(c112), "missed c112")
    
    XCTAssertEqual (c11.successor!, c111, "c11 successor c111")
    XCTAssertNotNil(c111.successor!, "c111 successor")
    XCTAssertEqual (c111.successor!, c112, "c111 successor c112")
    
    var ar : [Me] = []
    var next : Me? = c1
    while (nil != next) {
    //for var next : Me? = c1; nil != next; next = next!.successor {
      ar.append(next!)
      next = next!.successor
    }
    XCTAssertEqual(ar, [c1, c11, c111, c112, c12], "success")
    
    //XCTAssertTrue(c1c.cont, <#message: String#>)
    
  }
  func testPerformanceExample() {
    self.measure() {
    }
  }
}
