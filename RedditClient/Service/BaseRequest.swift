//
//  BaseRequest.swift
//  RedditClient
//
//  Created by Manu Herrera on 02/12/2018.
//  Copyright © 2018 Manu Herrera. All rights reserved.
//

import UIKit

class BaseRequest {
    
    private var url: URL!
    private var method: HTTPMethod
    private var body: Data?
    private var queryParams: [String: Any]?
    private var headers: [String: String]?
    var request: URLRequest
    
    init(_ url: URL, _ method: HTTPMethod,
         body: Data? = nil, queryParams: [String: Any]? = nil) {
        
        self.url = url
        self.method = method
        self.queryParams = queryParams
        self.body = body
        
        if let qp = queryParams, qp.count > 0 {
            var urlComponents = URLComponents(string: self.url.absoluteString)
            urlComponents?.queryItems = []
            for item in qp {
                let queryItem = URLQueryItem(name: item.key, value: String(describing: item.value))
                urlComponents?.queryItems?.append(queryItem)
            }
            self.url = urlComponents?.url
        }
        
        request = URLRequest(url: self.url)
        request.httpBody = body
        request.httpMethod = method.rawValue
    }
    
    func addHeader(key: String, value: String) -> Self {
        request.addValue(value, forHTTPHeaderField: key)
        return self
    }
    
}
