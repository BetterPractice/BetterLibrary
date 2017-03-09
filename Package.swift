//
//  Package.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 1/21/17.
//
//  Copyright 2017 Better Practice Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


import PackageDescription

var package = Package(
    name: "BetterLibrary"
)
let asyncTarget = Target(
    name: "Async",
    dependencies: []
)
let modelTarget = Target(
    name: "Model",
    dependencies: []
)
let networkTarget = Target(
    name: "NetworkServices",
    dependencies: [
        .Target(name: "Async"),
        .Target(name: "Model"),
        ]
)

package.targets = [asyncTarget, modelTarget, networkTarget]

