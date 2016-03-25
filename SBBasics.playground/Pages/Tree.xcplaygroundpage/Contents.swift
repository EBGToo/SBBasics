//: [Previous](@previous)

//import Foundation

var str = "Hello, playground"
1

func maxX<T:BinaryInteger> (_ x: T, _ y: T) -> T {
  return x > y ? x : y
}

//: [Next](@next)
enum Color { case R, B }

enum Order { case PreOrder, InOrder, PostOrder }

enum BinaryTree<Item: Comparable> {
  case empty
  indirect case node(Color, BinaryTree<Item>, Item, BinaryTree<Item>)
  
  init() { self = .empty }
  
  init(_ item: Item,
    color: Color = .B,
    left : BinaryTree<Item> = .empty,
    right: BinaryTree<Item> = .empty)
  {
    self = .node(color, left, item, right)
  }
  
  init (items: Array<Item>) {
    self = items.reduce(BinaryTree<Item>()) { $0.insert($1) }
  }
  
  var item : Item? {
    switch self {
    case .empty: return nil
    case let .node (_, _, item, _): return item
    }
  }
  
  var left : BinaryTree<Item>? {
    switch self {
    case .empty: return nil
    case let .node (_, left, _, _): return left
    }
  }
  
  var right : BinaryTree<Item>? {
    switch self {
    case .empty: return nil
    case let .node (_, _, _, right): return right
    }
  }
  
  var isempty : Bool {
    switch self {
    case .empty: return true
    case .node: return false
    }
  }
  
  var count : Int {
    switch self {
    case .empty: return 0
    case let .node (_, left, _, right):
      return 1 + left.count + right.count
    }
  }
  
  var degree : Int? {
    switch self {
    case .empty: return nil
    case let .node (_, left, _, right):
      return (left.isempty ? 0 : 1) + (right.isempty ? 0 : 1)
    }
  }
  
  var height : Int {
    switch self {
    case .empty: return 0
    case let .node (_, left, _, right):
      return 1 + maxX (left.height, right.height)
    }
  }
  
  func depth (_ item: Item) -> Int? {
    switch self {
    case .empty: return nil
    case let .node(_, left, that, right):
      if item < that { return left.depth (item).map { 1 + $0 } }
      if item > that { return right.depth(item).map { 1 + $0 } }
      return 0
    }
    
  }
  
  func contains(_ item: Item) -> Bool {
    return nil != lookup(item)
  }
  
  func lookup (_ item: Item) -> BinaryTree<Item>? {
    switch self {
    case .empty: return nil
    case let .node(_, left, that, right):
      if item < that { return left.lookup (item) }
      if item > that { return right.lookup(item) }
      return self
    }
  }
  
  /*
  func successor () -> BinaryTree<Item>?  {
    switch self {
    case .empty: return nil
    case let .node(_, left, that, right):
      return nil
    }
  }
  
  func predecessor () -> BinaryTree<Item>? {
    switch self {
    case .empty: return nil
    case let .node(_, left, that, right):
      return nil
    }
  }
  */
  
  func balance() -> BinaryTree<Item> {
    switch self {
    case let .node(.B, .node(.R, .node(.R, a, x, b), y, c), z, d):
      return .node(.R, .node(.B,a,x,b), y, .node(.B,c,z,d))
      
    case let .node(.B, .node(.R, a, x, .node(.R, b, y, c)), z, d):
      return .node(.R, .node(.B,a,x,b), y, .node(.B,c,z,d))
      
    case let .node(.B, a, x, .node(.R, .node(.R, b, y, c), z, d)):
      return .node(.R, .node(.B,a,x,b), y, .node(.B,c,z,d))
      
    case let .node(.B, a, x, .node(.R, b, y, .node(.R, c, z, d))):
      return .node(.R, .node(.B,a,x,b), y, .node(.B,c,z,d))
      
    default:
      return self
    }
  }
  
  func ins2 (_ x: Item) -> BinaryTree<Item> {
    guard case let .node(c, l, y, r) = self
      else { return BinaryTree(x, color: .R) }
    
    if x < y { return BinaryTree(y, color: c, left: l.ins2(x), right: r).balance() }
    if y < x { return BinaryTree(y, color: c, left: l, right: r.ins2(x)).balance() }
    return self
  }
  
  
  func insert2(_ x: Item) -> BinaryTree {
    guard case let .node(_,l,y,r) = self.ins2(x)
      else { fatalError("ins should never return an empty tree") }
    
    return .node(.B,l,y,r)
  }
  
  func insertInternal (_ item: Item) -> BinaryTree<Item> {
    switch self {
    case .empty: return BinaryTree(item, color: .R)
    case let .node (color, left, that, right):
      if item < that { return BinaryTree(that, color: color, left: left.insertInternal(item), right: right).balance() }
      if item > that { return BinaryTree(that, color: color, left: left, right: right.insertInternal(item)).balance() }
      return self
    }
  }
  
  func insert (_ item: Item) -> BinaryTree<Item> {
    switch insertInternal(item) {
    case .empty: fatalError ("impossible")
    case let .node (_, left, item, right):
      return .node(.B, left, item, right)
    }
  }
  
  func walk (_ order : Order) -> BinaryTreeIterator<Item> {
    return BinaryTreeIterator (tree: self, order: order)
  }
  
  func walk (_ f: (Item) -> Void, order: Order) {
    switch self {
    case .empty: return
    case let .node (_, left, item, right):
      if (Order.PreOrder == order)  { f (item) }
      left.walk(f, order: order)
      if (Order.InOrder == order)   { f (item) }
      right.walk(f, order: order)
      if (Order.PostOrder == order) { f (item) }
    }
  }
}

extension BinaryTree : ExpressibleByArrayLiteral {
  init(arrayLiteral elements: Item...) {
    self = elements.reduce(BinaryTree<Item>()) { $0.insert($1) }
  }
}

extension BinaryTree : Sequence {
  func makeIterator() -> BinaryTreeIterator<Item> {
    return walk(.InOrder)
  }
}

struct BinaryTreeIterator<Item:Comparable> : IteratorProtocol {
  let order : Order
  //let tree  : BinaryTree<Item>
  var stack = Stack<BinaryTree<Item>>()

  init (tree: BinaryTree<Item>, order: Order) {
    self.order = order
    switch tree {
    case .empty: break
    case .node: stack.push(tree)
    }
  }
  
  mutating func next () -> Item? {
    guard var top = stack.top() else { return nil }
    
    // Go left
    while case let .node (_, left, _, _) = top {
      if !left.isempty {
        stack.push(left)
        top = left
      }
    }
    
    if case let .node (_, _, _, right) = top { stack.push (right) }
    else { stack.pop() }
    
    return top.item!
  }
}

struct Stack<Item> {
  var items = Array<Item>()
  
  mutating func push (_ item: Item) {
    items.append(item)
  }
  
  mutating func pop () -> Item? {
    if items.isEmpty { return nil }
    return items.removeLast()
  }
  
  func top () -> Item? {
    return items.last
  }
}

/*
extension BinaryTree : ArrayLiteralConvertible {
  init(arrayLiteral elements: Self.Element...) {
    return elements.reduce (BinaryTree<Item>()) { $0.insert($1) }
  }
}
*/

/*
var t1 = BinaryTree(10)
var t2 = t1.insert2(5)
var t3 = t2.insert2(0)
t3.item
t3.left?.item
t3.right?.item

var t4 = t3.insert2(15)
t4.item
t4.left?.item
t4.right?.item
t4.left?.left?.item
t4.left?.right?.item

var t5 = t4.insert2(2)
*/

/*
var tt = BinaryTree<Int>(arrayLiteral: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
tt.right?.height
tt.left?.height

tt.depth(4)
tt.depth(0)
tt.depth(9)
tt.item
tt.depth(3)

tt.lookup(9)
*/

/*
var tx = BinaryTree(items: Array(0..<100))
tx.left?.height
tx.right?.height
*/

var ty = BinaryTree<Int>()
var n = 10
for _ in 0..<n {
  ty = ty.insert (Int(0 /* arc4random() */) % n)
}
ty.count
ty.left?.height
ty.right?.height

var tz = BinaryTree<Int>()
var m = 10
for _ in 0..<m {
  tz = tz.insert2 (Int(0 /* arc4random() */) % m)
}
tz.count
tz.left?.height
tz.right?.height

/*/
var ar = Array<Int>()
for item in tz {
  ar.append(item)
}
ar
*/

enum Tree<Item> {
  case leaf(Item)
  case node(Item, Array<Tree<Item>>)
  
  init (item: Item) {
    self = .leaf(item)
  }
  
  init (item: Item, children: [Tree<Item>]) {
    self = .node(item, children)
  }
  
  // Nope: Where to insert
  func insert (item: Item) -> Tree<Item> {
      return .leaf(item)
  }
  
  func addChild (child: Tree<Item>) -> Tree<Item> {
    switch self {
    case .leaf (let this): return .node (this, [child])
    case .node (let this, var children):
      children.append(child)
      return .node (this, children)
    }
  }
}

1


enum List<T> {
  case none
  indirect case cons (T, List<T>)
}

let lempty = List<Int>.none
lempty

let lone = List.cons (1, List.none)
lone


