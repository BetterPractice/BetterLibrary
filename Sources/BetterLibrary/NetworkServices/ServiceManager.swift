//
//  ServiceManager.swift
//  BetterLibrary NetworkServices
//
//  Created by Holly Schilling on 3/8/17.
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

open class ServiceManager {
    
    public enum ServiceError: Error {
        case missingData
        case missingResponse
    }
    
    public let session: URLSession
    public let workQueue: OperationQueue = OperationQueue()
    
    
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    open func fetchAndParse<ParserType: Parser>(url: URL, parser: ParserType) -> AsyncTask<ParserType.OutputType> where ParserType.InputType == (Data, URLResponse) {
        let request = URLRequest(url: url)
        return fetchAndParse(request: request, parser: parser)
    }
    
    open func fetchAndParse<ParserType: Parser>(request: URLRequest, parser: ParserType) -> AsyncTask<ParserType.OutputType> where ParserType.InputType == (Data, URLResponse) {
        
        let asyncTask: AsyncTask<ParserType.OutputType> = AsyncTask()
        
        let networkTask = session.dataTask(with: request) { (data, response, networkError) in
            if let networkError = networkError {
                asyncTask.setError(networkError)
                return
            }
            guard let data = data else {
                asyncTask.setError(ServiceError.missingData)
                return
            }
            guard let response = response else {
                asyncTask.setError(ServiceError.missingResponse)
                return
            }
            
            self.workQueue.addOperation {
                guard parser.canParse((data, response)) else {
                    asyncTask.setError(ParserError.parserDeclined)
                    return
                }
                do {
                    let result = try parser.parse((data, response))
                    asyncTask.setResult(result)
                }
                catch {
                    asyncTask.setError(error)
                }
            }
        }
        
        networkTask.resume()
        return asyncTask
    }

    //MARK: - Data Parsing Methods
    
    open func fetchAndParse<ParserType: Parser>(url: URL, dataParser: ParserType) -> AsyncTask<ParserType.OutputType> where ParserType.InputType == Data {
        let request = URLRequest(url: url)
        return fetchAndParse(request: request, dataParser: dataParser)
    }
    
    open func fetchAndParse<ParserType: Parser>(request: URLRequest, dataParser: ParserType) -> AsyncTask<ParserType.OutputType> where ParserType.InputType == Data {
        let parser = StageHTTPURLResponseParser(nextParser: dataParser)
        return fetchAndParse(request: request, parser: parser)
    }
    
    //MARK: - Model Parsing Methods
    
    open func fetchAndParse<ParserType: Parser>(url: URL, modelParser: ParserType, at parsingPath: [Any] = []) -> AsyncTask<ParserType.OutputType> where ParserType.InputType == Model {
        let request = URLRequest(url: url)
        return fetchAndParse(request: request, modelParser: modelParser, at: parsingPath)
    }
    
    open func fetchAndParse<ParserType: Parser>(request: URLRequest, modelParser: ParserType, at parsingPath: [Any] = []) -> AsyncTask<ParserType.OutputType> where ParserType.InputType == Model {
        let parser = StageModelJSONParser(nextParser: modelParser)
        parser.startPath = parsingPath
        return fetchAndParse(request: request, dataParser: parser)
    }
    
}
