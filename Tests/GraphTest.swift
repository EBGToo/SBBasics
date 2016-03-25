//
//  GraphTest.swift
//  SBBasics
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import XCTest
import SBCommons
@testable import SBBasics

class GraphTest: XCTestCase {

  override func setUp() {
    super.setUp()
  }
    
  override func tearDown() {
    super.tearDown()
  }

  func testExample() {
    let g1 : Graph<Int, Int> = Graph()
    var pathCount = 0;

    XCTAssertTrue(0 == g1.countOfNodes, "zero nodes")
    XCTAssertTrue(0 == g1.countOfEdges, "zero edges")

    g1.addNode (1)
    XCTAssertTrue(1 == g1.countOfNodes, "one node")
    XCTAssertTrue(g1.hasNode(1), "has node '1'")
    
    g1.addNode (2)
    XCTAssertTrue(2 == g1.countOfNodes, "two nodes")
    XCTAssertTrue(g1.hasNode(2), "has node '2'")
    
    g1.addEdge (100, source: 1, target: 2)
    XCTAssertTrue(1 == g1.countOfEdges, "one edge")
    XCTAssertTrue(g1.hasEdge(100), "has edge '100'")
    
    // (1) -> (2)
    
    pathCount = 0
    g1.walkPaths ([1]) { (path: List<Int>) in
      pathCount += 1
      XCTAssertTrue(path.contains(1), "path: 1")
      XCTAssertTrue(path.contains(2), "path: 2")
      XCTAssertFalse(path.contains(3), "path: 0")
    }
    XCTAssertEqual(1, pathCount, "one path")
    
    g1.addNode (3)
    XCTAssertTrue(3 == g1.countOfNodes, "tre nodes")
    XCTAssertTrue(g1.hasNode(3), "has node '3'")
    
    g1.addEdge (200, source: 1, target: 3)
    XCTAssertTrue(2 == g1.countOfEdges, "two edge")
    XCTAssertTrue(g1.hasEdge(200), "has edge '200'")
    
    // (1) -> (2), (1) -> (3)
    
    pathCount = 0
    g1.walkPaths ([1]) { (path: List<Int>) in
      pathCount += 1
      XCTAssertNotNil(path.contains(1), "path: 1")
      //      XCTAssertTrue(path.has(1, pred: ==), "path: 1")
      XCTAssertTrue(path.contains (2) || path.contains(3), "path: 2/3")
      XCTAssertFalse(path.contains(0), "path: 0")
    }
    XCTAssertEqual(2, pathCount, "two paths")
    
    g1.addNode(4)
    g1.addNode(5)
    g1.addEdge(300, source: 4, target: 5)
    //g1.addEdge(400, source: 5, target: 4)
    
    let cc = g1.connectedComponents
    
    XCTAssertTrue (cc.contains(1), "cc 1")
    XCTAssertTrue (cc.contains(4), "cc 4")
    
    let mst1 = g1.minimalSpanningTree
    
    XCTAssertTrue (mst1.contains(100), "edge 100")
    XCTAssertTrue (mst1.contains(200), "edge 200")
    XCTAssertTrue (mst1.contains(300), "edge 300")
    
  }
  
  func testTopologicalSort () {
    let g : Graph<String, String> = Graph()
    
    let nodes : [String] = [
      "undershorts", "pants", "belt", "shirt", "tie",
      "jacket", "socks", "shoes", "watch"]
      
    nodes.app(g.addNode)
    
    let edges : [(String, String)] = [
      ("undershorts", "pants"),
      ("undershorts", "shoes"),
      ("pants", "shoes"),
      ("pants", "belt"),
      ("shirt", "belt"),
      ("shirt", "tie"),
      ("tie",   "jacket"),
      ("belt",  "jacket"),
      ("socks", "shoes")]

    edges.app { (n1:String, n2:String) in
      g.addEdge(n1 + "->" + n2,
        source: n1,
        target: n2)
    }
    
    let result : [String] = g.topologicalSort.array.map { (n:String) -> String in return n }
    
    print("==== Topological Sort: " + result.description)
    
    func finder (_ r:[String]) -> (String) -> Array<String>.Index {
      return { (s:String) -> Array<String>.Index in
        return r.firstIndex(of: s)!
      }
    }

    let lu = finder(result)
    
    nodes.app { (n:String) in
        XCTAssertNotNil(result.firstIndex(of: n), "missed: " + n)
      return
    }
    
    edges.app { (s1, s2) -> Void in
      XCTAssertLessThan(lu(s1), lu(s2), "1")
    }
  }
  
  func testShortestPath () {
    let g : Graph<String, String> = Graph()
    
    let nodes : [String] = ["a", "b", "c", "d", "e"]
    nodes.app(g.addNode)
    
    let edges : [(String, String, Double)] = [
      ("a", "b", 1.0),
      ("b", "c", 2.0),
      ("a", "d", 5.0),
      ("b", "d", 3.0),
      ("c", "e", 4.0),
      ("a", "e", 9.0)
    ]
    
    edges.app { (n1:String, n2:String, w:Double) in
      g.addEdge(n1 + "->" + n2,
        source: n1,
        target: n2,
        weight: w)
    }

    // Result: Weights and Links
    let rw = ["a":0.0, "b":1.0, "c":3.0, "d":4.0, "e":7.0]
    let rl = [         "b":"a", "c":"b", "d":"b", "e":"c"]
    
    // Actual work
    let sp = g.shortestPath("a")

    XCTAssertNotNil(sp["a"], "a")
    XCTAssertEqual(sp["a"]!.wgt, rw["a"]!, "a")
    XCTAssertNil(sp["a"]!.lnk, "a")
    
    XCTAssertNotNil(sp["b"], "b")
    XCTAssertEqual(sp["b"]!.wgt,  rw["b"]!, "b")
    XCTAssertEqual(sp["b"]!.lnk!, rl["b"]!, "b")

    XCTAssertNotNil(sp["c"], "c")
    XCTAssertEqual(sp["c"]!.wgt,  rw["c"]!, "c ")
    XCTAssertEqual(sp["d"]!.lnk!, rl["c"]!, "c")
    
    XCTAssertNotNil(sp["d"], "d")
    XCTAssertEqual(sp["d"]!.wgt,  rw["d"]!, "d")
    XCTAssertEqual(sp["d"]!.lnk!, rl["d"]!, "d")
    
    XCTAssertNotNil(sp["e"], "e")
    XCTAssertEqual(sp["e"]!.wgt,  rw["e"]!, "e")
    XCTAssertEqual(sp["e"]!.lnk!, rl["e"]!, "e")
  }
  
  func testPerformanceExample() {
    self.measure() {
    }
  }
}
  
