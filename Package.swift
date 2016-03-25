// swift-tools-version:5.3
//
//  Package.swift
//  SBBasics
//
//  Created by Ed Gamble on 12/3/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
import PackageDescription

let package = Package(
    name: "SBBasics",
    platforms: [
        .macOS("11.1")
    ],

    products: [
        .library(
            name: "SBBasics",
            targets: ["SBBasics"]),
    ],

    dependencies: [
        .package(path: "../SBCommons")
    ],

    targets: [
        .target(
            name: "SBBasics",
            dependencies: ["SBCommons"],
            path: "Sources"
        ),
        .testTarget(
            name: "SBBasicsTests",
            dependencies: ["SBBasics"],
            path: "Tests"
        ),
    ]
)
