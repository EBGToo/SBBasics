//
//  ListLazyTest.swift
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

class ctxxTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func mapperWith (_ label:String, f: @escaping (Int) -> Int) -> (Int) -> Int {
    return { (i:Int) in
      print ("\(label): \(i)")
      return f(i)
    }
  }
  
  func filterWith (_ label:String, pred: @escaping (Int) -> Bool) -> (Int) -> Bool {
    return { (i:Int) in
      print ("\(label): \(i)")
      return pred(i)
    }
  }
  
  func testLazySequence() {
    let a1 = [1, 2, 3]
    
    func mapper (_ label:String) -> (Int) -> Int {
      return { (i:Int) in
        print ("\(label): \(i)")
        return i * 10
      }
    }
    
    print ("Map")
    let l1 = a1.lazy.map (mapperWith("L") { $0 * 10 })
    for l in l1 { print ("A: \(l)") }
    for l in l1 { print ("B: \(l)") }
    
    print ("Filter")
    let l2 = a1.lazy.filter(filterWith("F") { 1 == $0 % 2})
    print ("  As"); for l in l2 { print ("A: \(l)") }
    print ("  Bs"); for l in l2 { print ("B: \(l)") }
    
    print ("Filter1")
    let l3 = [1,2,3,4,5,6,7,8,9,10].lazy
      .filter {i in print("A: \(i)"); return 0 == i % 2} // even
      .filter {i in print("B: \(i)"); return 1 == (i / 2) % 2} // 2, 6, 10
      .filter {i in print("C: \(i)"); return i < 10} // 2, 6
    for l in l3 { print ("XX: \(l)") }
    print ("Filter1X")
    for l in l3 { print ("XX: \(l)") }
    
    print ("Filter2")
    let l4 = List(elements:[1,2,3,4,5,6,7,8,9,10]).lazy
      .filter {i in print("A: \(i)"); return 0 == i % 2} // even
      .filter {i in print("B: \(i)"); return 1 == (i / 2) % 2} // 2, 6, 10
      .filter {i in print("C: \(i)"); return i < 10} // 2, 6
    l4.app { print ("XX: \($0)") }
    print ("Filter2X")
    l4.app { print ("XX: \($0)") }
    
    //    l4.forEach { print ("XX: \($0)") }
  }
  
  func testLazyForEach() {
    let l1 : List<Int> = [1, 2, 3, 4, 5]
    _ = l1.lazy
    
    //    ll1.forEach {
    //  print ("FE: \($0)")
    //}
    
    print ("MMFE")
    l1.lazy.map(mapperWith("M") { $0 * 10}).app {
      print ("MFE: \($0)")
    }
    
    print ("FFFE")
    l1.lazy.filter(filterWith("F") { 5 == $0 }).app {
      print ("FFE: \($0)")
    }
  }
  
  func testLazy() {
    let l1 : List<Int> = [1, 2, 3]
    
    XCTAssertFalse(l1.isEmpty)
    
    let ll1 = l1.lazy
    
    XCTAssertEqual(ll1.car, 1)
    XCTAssertEqual(ll1.cdr?.car, 2)
    XCTAssertEqual(ll1.cdr?.cdr?.car, 3)
  }
  
  func testLazyMap() {
    let l1 : List<Int> = [1, 2, 3]
    
    XCTAssertFalse(l1.isEmpty)
    
    let ll1 = l1.lazy.map { $0 * 10 }
    
    XCTAssertEqual(ll1.car, 10)
    XCTAssertEqual(ll1.cdr?.car, 20)
    XCTAssertEqual(ll1.cdr?.cdr?.car, 30)
  }
  
  func testLazyFilter() {
    let l1 : List<Int> = [1, 2, 3]
    
    XCTAssertFalse(l1.isEmpty)
    
    let ll1 = l1.lazy.filter { 1 == $0 % 2 }
    
    XCTAssertEqual(ll1.car, 1)
    XCTAssertEqual(ll1.cdr?.car, 3)
  }
  
  func testLazyMapFilter() {
    let l1 : List<Int> = [1, 2, 3]
    
    XCTAssertFalse(l1.isEmpty)
    
    let ll1 = l1.lazy
      .map { $0 + 10 }
      .filter { 1 == $0 % 2 }
    
    XCTAssertEqual(ll1.car, 11)
    XCTAssertEqual(ll1.cdr?.car, 13)
    XCTAssertNil(ll1.cdr?.cdr?.car)
    
    let ll2 = List<Int>(arrayLiteral: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10).lazy
      .filter {i in print("A: \(i)"); return 0 == i % 2} // even
      .filter {i in print("B: \(i)"); return 1 == (i / 2) % 2} // 2, 6, 10
      .filter {i in print("C: \(i)"); return i < 10} // 2, 6
    
    //ll2.forEach { print ("FE: \($0)") }
    
    let ll2_1 = ll2
    print ("_1")
    let ll2_2 = ll2.cdr
    print ("_2")
    let ll2_3 = ll2.cdr?.cdr
    print ("_3")
    
    XCTAssertEqual(ll2_1.car, 2)
    XCTAssertEqual(ll2_2?.car, 6)
    XCTAssertNil(ll2_3?.car)
  }
  
  func testLazyDrop() {
    let l1 : List<Int> = [1, 2, 3, 4, 5]
    let d1 = l1.lazy.drop(2);
    
    XCTAssertEqual(d1.car, 3)
  }
  
  func testLazyTake() {
    let l1 : List<Int> = [1, 2, 3, 4, 5]
    let t1 = l1.lazy.take(2)
    
    XCTAssertEqual(t1.car, 1)
    XCTAssertEqual(t1.cdr!.car, 2)
    XCTAssertNil(t1.cdr!.cdr!.car)
    XCTAssertNil(t1.cdr!.cdr!.cdr)
  }
  
  func testPerformanceExample() {
    self.measure {
    }
  }
}
