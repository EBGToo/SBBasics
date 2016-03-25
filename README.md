# Bags, Stacks, Queues, Lists, Heaps, Trees, Graphs

Basics is a collection of largely standalone Swift abstractions for Bag type.

![License](https://img.shields.io/cocoapods/l/SBBasics.svg)
[![Language](https://img.shields.io/badge/lang-Swift-orange.svg?style=flat)](https://developer.apple.com/swift/)
![Platform](https://img.shields.io/cocoapods/p/SBBasics.svg)
![](https://img.shields.io/badge/Package%20Maker-compatible-orange.svg)
[![Version](https://img.shields.io/cocoapods/v/SBBasics.svg)](http://cocoapods.org)

## Features

### Bags

A `Bag` defines a minimalistic, narrowly-interfaced container protocol for an arbitrary number
of specifically typed but otherwise arbitary Items.  A Bag may hold numerous 'duplicate' items.
Generally the ordering of items in a bag is upspecified and the contents of the bag are (meant 
to be) invisible.  One does not sequence through the bag contents nor does one index into the 
bag.  There are other Swift data structures that allow for sequencing and indexing.

### Stacks

A `Stack` holds elements according to a LIFO discipline.  Elements are pushed onto the top of 
a stack and popped off of the top. 

### Queues

A `Queue` holds elements according to a FIFO discipline.  Elements are enqueued and dequeued.

### Lists

A `List` holds elements according to a LIST discipline whereby the list is wither Empty or
contains an Item as the `car` (aka head) and another list as the `cdr` (tail).

### Heaps

A `Heap` stores items according to a 'Priority Heap' discipline based on a ordering defined for
`Comparable` items

### Rings

A `Ring` hold items according to a RING discipline whereby items are `put` to the tail of the ring
and `get` from the head of the ring.  If the ring is filled to capacity, then `put` will discard
the oldest item.

### Trees

A `Tree` holds items items according to a rooted TREE discipline.

### Graphs

A `Graph` is a set of Items (as Nodes) connected to one anther (with Edges, possibly weighted).

## Usage

Access the framework with

```swift
import SBBasics
```

## Installation

Three easy installation options:

### Apple Package Manager

In your Package.swift file, add a dependency on SBBasics:

```swift
import PackageDescription

let package = Package (
  name: "<your package>",
  dependencies: [
    // ...
    .Package (url: "https://github.com/EBGToo/SBBasics.git",  majorVersion: 0),
    // ...
  ]
)
```

### Cocoa Pods

```ruby
pod 'SBBasics', '~> 0.1'
```

### XCode

```bash
$ git clone https://github.com/EBGToo/SBBasics.git SBBasics
```

Add the SBBasics Xcode Project to your Xcode Workspace; you'll also need the [SBCommons](https://github.com/EBGToo/SBCommons) package
as well
