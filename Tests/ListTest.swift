//
//  ListTest.swift
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

//#if os(iOS)
//import OpusIOS
//#else
//import OpusOSX
//#endif

class ListTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testExample() {
    // This is an example of a functional test case.
    XCTAssert(true, "Pass")
  }
  
  func testInit () {
    let li : List<Int> = List()
    
    XCTAssertTrue (li.isEmpty, "== List.isEmpty")
    XCTAssertTrue (0  == li.count, "0 == count")
    
    let l1 = List<Int> (10)
    XCTAssertTrue( 1 == l1.count, "1 == count")
    XCTAssertTrue(10 == l1.last,  "10 == last")
    XCTAssertTrue(10 == l1[0],"10 == nth(0)")
    // XCTAssertTrue(nil == l1.nth(1),"nil== nth(1)")
    
    let l2 = List<Int> (20, l1)
    XCTAssertTrue( 2 == l2.count, "2  == count")
    XCTAssertTrue(10 == l2.last,  "10 == last")
    XCTAssertTrue(20 == l2[0],"20 == nth(0)")
    XCTAssertTrue(10 == l2[1],"10 == nth(1)")
    // l2[10]
  }

  func testListArrayLiteral () {
    var l1 : List<Int> = [1, 2, 3]
    
    XCTAssertEqual(3, l1.count, "3 == count")
    
    l1 = List(0, l1)
    XCTAssertEqual(4, l1.count, "4 == count")    
  }
  
  func testListEqual () {
    let l1 : List<Int> = [1, 2, 3]
    let l2 : List<Int> = [1, 2, 3]
    let l3 : List<Int> = [3, 2, 1]
    
    XCTAssertTrue(l1.equalToList(l2, pred: ==), "l1 == l2")
    XCTAssertFalse(l1.equalToList(l3, pred: ==), "l1 != l3")
    XCTAssertFalse(l1.equalToList(l2.cdr!, pred: ==), "l1 != l2.tail")
  }
  
  func testListReverse () {
    let l1 : List<Int> = [1, 2, 3]
    let l2 : List<Int> = [1, 2, 3]
    let l3 : List<Int> = [3, 2, 1]
    
    let r1 : List<Int> = l1.reverse
    
    XCTAssertEqual(3, r1.count, "l1.rev.count == 3")
    XCTAssertTrue(r1.equalToList(l3, pred: ==), "l1.rev == l3")
    
    XCTAssertTrue(l2.reverse.equalToList(l3, pred: ==), "l2.rev == l3")
  }
  
  func testListMap () {
    let l1 : List<Int> = [1, 2, 3]
    let l2 : List<Int> = [2, 4, 6]
    
    let l3 : List<Int> = l1.map { 2 * $0 }
    
    XCTAssertTrue(l3.equalToList(l2, pred: ==), "l3 == 2*l1")
  }
  
  func testListFilter () {
    let l1 : List<Int> = [1, 2, 3]
    let l2 : List<Int> = [1, 3]
    
    let l3 : List<Int> = l1.filter { 1 == $0  % 2 }
    
    print (l3)
    XCTAssertTrue(l3.equalToList(l2, pred: ==), "l2 == l1.odds")
  }
  
  func testListPartition () {
    let l1 : List<Int> = [1, 2, 3, 4]
    
    let l1l : List<Int> = [2, 4]
    let l1r : List<Int> = [1, 3]
    
    let (l2l, l2r) : (List<Int>, List<Int>) = l1.partition { 0 == $0 % 2 }
    
    XCTAssertTrue(l2l.equalToList(l1l, pred: ==))
    XCTAssertTrue(l2r.equalToList(l1r, pred: ==))
  }

  func testListFoldL () {
    let l1 : List<Int> = [1, 2, 3]
    
    XCTAssertEqual( 6, l1.foldl(0, combine: +))
    
    // ((0 - 1) - 2) - 3) = (-1 - 2) - 3 =  -3 - 3 = -6
    XCTAssertEqual(-6, l1.foldl(0, combine: -))
    
  }
  
  func testListFoldR () {
    let l1 : List<Int> = [1, 2, 3]
    
    XCTAssertEqual( 6, l1.foldr(0, combine: +))
    
    // (1 - (2 - (3 - 0))) = 1 - (2 - 3) = (1 - -1) = 2
    XCTAssertEqual(2, l1.foldr(0, combine: -))
    
  }
  
  func testListCollectionType () {
    let l1 : List<Int> = [1, 2, 3]
    
    XCTAssertFalse(l1.isEmpty);
    XCTAssertTrue(List<Int>().isEmpty);
    
    XCTAssertEqual(1, l1.first ?? 0)
    XCTAssertEqual(3, l1.last ?? 0)
    
    XCTAssertNil(List<Int>().first)
    XCTAssertNil(List<Int>().last)
    
//    XCTAssertEqual(1, l1.indexOf { 0 == $0 % 2 } ?? 0)
//    XCTAssertEqual(1, l1.indexOf (2))
    
//    XCTAssertEqual(2, l1.find { 0 == $0 % 2 } ?? 0)
  }
  
  func testListSequenceLogicType () {
    let l1 : List<Int> = [1, 3, 5]
    let l2 : List<Int> = [1, 2, 3, 4, 5]

    XCTAssertTrue(l1.all { 1 == $0 % 2 })
    XCTAssertTrue(l1.any { 1 == $0 % 2 })
    
    XCTAssertFalse(l2.all { 1 == $0 % 2 })
    XCTAssertTrue (l2.any { 1 == $0 % 2 })
/*
    let allEven = allWith { 0 == $0 % 2 }
    let allOdd  = allWith { 1 == $0 % 2 }
    
    XCTAssertFalse(allEven(l1))
    XCTAssertTrue (allOdd (l1))

    let anyEven = anyWith { 0 == $0 % 2 }
    let anyOdd  = anyWith { 1 == $0 % 2 }
    
    XCTAssertFalse(anyEven(l1))
    XCTAssertTrue (anyOdd (l1))
    XCTAssertTrue (anyEven(l2))
    XCTAssertTrue (anyOdd (l2))
*/
  }
  
  func XtestPerformanceExample() {
    // This is an example of a performance test case.
    self.measure() {
    // Put the code you want to measure the time of here.
    }
  }
}
