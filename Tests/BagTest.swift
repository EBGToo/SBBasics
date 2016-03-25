//
//  BagTest.swift
//  SBBasics
//
//  Created by Ed Gamble on 11/20/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
import XCTest
@testable import SBBasics

class BagTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testExample() {
    var b1 = Bag(arrayLiteral: 1,2,3)
    
    XCTAssertTrue (b1.contains(1))
    XCTAssertTrue (b1.contains(2))
    XCTAssertTrue (b1.contains(3))
    XCTAssertFalse(b1.contains(4))
    
    b1.insert(10)
  }
  
  func testPerformanceExample() {
    self.measure {
    }
  }
}
