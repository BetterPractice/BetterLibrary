//
//  StaticNetworkDataEmulator.swift
//  BetterLibrary
//
//  Created by Holly Schilling on 5/7/17.
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

import Foundation
import Dispatch

public class StaticNetworkDataEmulator: NetworkDataProvider {
    
    public var latency: TimeInterval = 0.01
    public var statusCode: Int = 200
    public var data: Data?
    
    private var backgroundQueue: DispatchQueue = DispatchQueue(label: "StaticNetworkDataEmulator Background Queue")
    
    public init(data: Data? = nil) {
        self.data = data
    }
    
    public func fetchData(for request: URLRequest) -> NetworkTask {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)
        let task = NetworkTask()
        
        backgroundQueue.asyncAfter(deadline: .now() + latency) {
            task.response = response
            if let data = self.data {
                task.setSuccess(data)
            } else {
                task.setError(NetworkDataError.missingData)
            }
        }
        
        return task
    }
}
