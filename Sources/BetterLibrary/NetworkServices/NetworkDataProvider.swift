//
//  NetworkDataProvider.swift
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

public enum NetworkDataError: Error {
    case missingData
    case missingResponse
}

public protocol NetworkDataProvider{
    
    func fetchData(for request: URLRequest) -> NetworkTask
}

extension URLSession: NetworkDataProvider {
    
    public func fetchData(for request: URLRequest) -> NetworkTask {
        let networkTask = NetworkTask()
        
        let task = self.dataTask(with: request) { (data, response, error) in
            networkTask.response = response
            if let error = error {
                networkTask.setError(error)
            } else if let data = data {
                networkTask.setSuccess(data)
            } else {
                networkTask.setError(NetworkDataError.missingData)
            }
        }
        networkTask.sessionTask = task
        task.resume()
        
        return networkTask
    }
}

