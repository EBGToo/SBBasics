//
//  QueueTest.swift
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
//  import OpusIOS
//  #else
//  import OpusOSX
//#endif


class QueueTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testQueue() {
    var queue = Queue<Int>()
    
    queue.enqueue (0)
    queue.enqueue (10)
    
    XCTAssertNotNil(queue.head!, "head")
    XCTAssertEqual( 0, queue.dequeue()!, "0")
    XCTAssertEqual(10, queue.dequeue()!, "10")
    
    queue.enqueue (20)
    XCTAssertTrue (queue.contains(20), "contains(20)")
    XCTAssertFalse(queue.contains(0), "contains( 0)")
    XCTAssertFalse(queue.contains(10), "contains(10)")
    
    XCTAssertNotNil(queue.head, "head")
    XCTAssertNotNil(queue.tail, "tail")
    XCTAssertEqual(20, queue.tail!, "tail 20")
  }
  
  func testQueueLiteral () {
    var queue : Queue<Int> = [0, 10, 20];
    
    XCTAssertNotNil(queue.head, "head")
    XCTAssertEqual( 0, queue.head!, "head: 0")
    XCTAssertEqual( 0, queue.dequeue()!, "dequeue: 0")
    XCTAssertEqual(10, queue.dequeue()!, "dequeue: 10")
    
    XCTAssertNotNil(queue.tail, "tail")
    XCTAssertEqual(20, queue.tail!, "tail: 20")
    XCTAssertEqual(20, queue.dequeue()!, "dequeue: 20")
    
    queue.enqueue(30)
    XCTAssertEqual(30, queue.tail!, "tail: 30")
    XCTAssertEqual(30, queue.dequeue()!, "dequeue: 30")
    
    XCTAssertTrue(queue.isEmpty, "empty")
    
  }
  
  func testPerformanceExample() {
    self.measure() {
    }
  }
}
