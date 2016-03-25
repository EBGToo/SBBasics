//
//  StackTest.swift
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

class StackTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testStackInt() {
    var stack = Stack<Int>()
    
    stack.push (10)
    XCTAssert(10 == stack.pop(), "Missed pop()")
    
    stack.push (0)
    XCTAssertTrue(stack.contains(0), "contains(0)")
    XCTAssertFalse(stack.contains(10), "contains(10)")
    
  }
  
  class Bar {}
  
  func testStackBar () {
    var stack = Stack<Bar>()
    
    let bar1 = Bar()
    let bar2 = Bar()
    
    XCTAssertTrue(0 == stack.count, "0")
    XCTAssertTrue(stack.isEmpty, "isEmpty")
    stack.push(bar1)
    stack.push(bar2)
    
    XCTAssertTrue(2 == stack.count, "count")
    XCTAssertFalse(stack.isEmpty, "isEmpty")
    
    XCTAssertTrue(bar2 === stack.top, "missed bar2==top")
    XCTAssertTrue(bar1 === stack.bottom, "missed bar1==bottom")
    XCTAssertTrue(bar2 === stack.pop(), "missed bar2==pop")
    
    XCTAssertTrue(bar1 === stack.top, "missed bar1==top")
    XCTAssertTrue(bar1 === stack.bottom, "missed bar1==top")
    XCTAssertTrue(bar1 === stack.pop(), "missed bar1==pop")
  }
  
  func testStackLiteral () {
    var s1 : Stack<Int> = [1,2,3]
    
    XCTAssertEqual(s1.pop()!, 1, "1")
    XCTAssertEqual(s1.pop()!, 2, "2")
    XCTAssertEqual(s1.pop()!, 3, "3")
    XCTAssertNil(s1.top, "empty")
    
    s1 = [1]
    s1.push(0)
    XCTAssertEqual(s1.pop()!, 0, "0")
    XCTAssertEqual(s1.pop()!, 1, "1")
    
  }
  
  func testStackContains () {
    let s1 : Stack<Int> = [1,2,3]
    
    XCTAssertTrue(s1.contains(1))
    XCTAssertTrue(s1.contains(2))
    XCTAssertTrue(s1.contains(3))
    XCTAssertFalse(s1.contains(4))
  }
  
  func XtestPerformanceExample() {
    self.measure() {
    }
  }
}
