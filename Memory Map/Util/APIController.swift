//
//  APIController.swift
//  Memory Map
//
//  Created by Mohonish Chakraborty on 13/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import Foundation

public struct APIError {
    
    var errorMessage = "Oops! Something went wrong. Please try again."
    var errorType: APIErrorType
    
    public init(errorType: APIErrorType) {
        self.errorType = errorType
    }
    
    public init(errorMessage: String, errorType: APIErrorType) {
        self.errorMessage = errorMessage
        self.errorType = errorType
    }
}

public enum APIErrorType {
    case invalidURL, noResponseData, jsonSerializationFail, errorResponse
}

public class APIController {
    
    fileprivate static let fetchImageEndpoint = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"
    
    public static func fetchImages(success: @escaping (_ response: [String: Any]) -> Void, failure: @escaping (_ error: APIError) -> Void) {
        GET(url: fetchImageEndpoint, success: success, failure: failure)
    }
    
}

extension APIController {
    
    fileprivate static func GET(url: String, success: @escaping (_ response: [String: Any]) -> Void, failure: @escaping (_ error: APIError) -> Void) {
        
        guard let url = URL(string: url) else {
            failure(APIError(errorType: .invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                failure(APIError(errorType: .errorResponse))
                return
            }
            
            guard let responseData = data else {
                failure(APIError(errorType: .noResponseData))
                return
            }
            
            do {
                guard let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    failure(APIError(errorType: .jsonSerializationFail))
                    return
                }
                success(responseJSON)
                
            } catch {
                failure(APIError(errorType: .jsonSerializationFail))
                return
            }
            
        })
        task.resume()
    }
    
}
