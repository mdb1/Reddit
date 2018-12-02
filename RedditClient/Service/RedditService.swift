//
//  RedditService.swift
//  RedditClient
//
//  Created by Manu Herrera on 02/12/2018.
//  Copyright © 2018 Manu Herrera. All rights reserved.
//

import UIKit

class RedditService {
    
    let session = URLSession.shared
    lazy public var baseURL = getBaseURL()
    
    public func getBaseURL() -> String {
        return "https://www.reddit.com/top/.json?limit=50"
    }
    
    var decoder = { () -> JSONDecoder in
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateStr)"
            )
        })
        return decoder
    }()
    
    func get<T: Codable>(queryParams: [String: Any]? = [:],
                         extraHeaders: [String: String]? = nil,
                         andReturn model: T.Type,
                         completion: @escaping ((Result<T>) -> Void)) {
        doRequest(.get,
                  queryParams: queryParams,
                  extraHeaders: extraHeaders,
                  andReturn: model,
                  completion: completion)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                completion(UIImage(data: data))
            }
        }
    }
    
    private func doRequest<T: Codable>(_ method: HTTPMethod,
                                       body: Data? = nil,
                                       queryParams: [String: Any]? = [:],
                                       extraHeaders: [String: String]? = nil,
                                       andReturn model: T.Type,
                                       completion: @escaping ((Result<T>) -> Void)) {
        
        guard let url = URL(string: "\(self.baseURL)") else {
            fatalError("URL NOT VALID")
        }
        
        let request = prepareRequest(url: url,
                                     method: method,
                                     body: body,
                                     queryParams: queryParams,
                                     extraHeaders: extraHeaders)
        
        let dataTask = self.session.dataTask(with: request.request) { (data, response, error) in
            
            if error != nil {
                completion(.error(UserError.defaultError))
                return
            }
            
            self.log(request, response, data)
            
            if let parsedResponse: T = self.parseData(data: data, model: model) {
                completion(.success(parsedResponse))
            } else {
                completion(.error(UserError.codableError))
            }
            
        }
        
        dataTask.resume()
        
    }
    
    private func prepareRequest(url: URL,
                                method: HTTPMethod,
                                body: Data?,
                                queryParams: [String: Any]?,
                                extraHeaders: [String: String]? = nil) -> BaseRequest {
        var request = BaseRequest(url, method, body: body, queryParams: queryParams)
            .addHeader(key: "Content-Type", value: "application/json")
            .addHeader(key: "Accept", value: "application/json")
        
        if let extraHead = extraHeaders {
            for (key, value) in extraHead {
                request = request.addHeader(key: key, value: value)
            }
        }
        
        return request
    }
    
    func parseData<T: Codable> (data: Data?, model: T.Type) -> T? {
        guard let data = data else {
            return nil
        }
        
        return try? decoder.decode(T.self, from: data)
    }
    
    fileprivate func log(_ request: BaseRequest, _ response: URLResponse?, _ data: Data?) {
        self.logRequest(request)
        if let r = response, let d = data {
            self.logResponse(r, data: d)
        }
    }
    
    private func logRequest(_ request: BaseRequest) {
        print()
        print("> ---")
        let method = request.request.httpMethod ?? "NO HTTP METHOD"
        let urlString = String(describing: request.request.url!)
        print("> \(method) \(urlString)")
        if let headers =  request.request.allHTTPHeaderFields {
            for header in headers {
                print("> \(header.key): \(header.value)")
            }
        }
        
        print()
        
        if let b = request.request.httpBody {
            print()
            guard let body = try? JSONSerialization.jsonObject(with: b, options: .allowFragments) else {
                return
            }
            print(body)
        }
    }
    
    private func logResponse(_ response: URLResponse, data: Data) {
        if let httpResponse = response as? HTTPURLResponse {
            print()
            print("< ---")
            let statusCode = httpResponse.statusCode
            print("< \(statusCode)")
            
            for header in httpResponse.allHeaderFields {
                print("< \(header.key): \(header.value)")
            }
            
            print()
            guard let body = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                return
            }
            print(body)
            print()
        }
    }
    
}

enum UserError: Error {
    case codableError
    case defaultError
}

enum Result<T> {
    case success(T)
    case error(Error)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
