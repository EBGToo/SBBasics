// swift-tools-version:5.5
//
//  Package.swift
//  SBBasics
//
//  Created by Ed Gamble on 12/3/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
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
        .package(url: "https://github.com/EBGToo/SBCommons", .upToNextMajor(from: "0.1.0"))
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
