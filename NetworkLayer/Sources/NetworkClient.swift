//
//  NetworkClient.swift
//  NetworkLayer
//
//  Created by Ivan Reinaldo on 3/20/22.
//

import Foundation

public protocol APIRequest {
    associatedtype Response: Decodable
    var urlRequest: URLRequest { get }
}

public protocol NetworkClient: AnyObject {
    func makeRequest<T: APIRequest>(_ request: T,
                                    responseQueue: DispatchQueue,
                                    completion: @escaping (Result<T.Response, Error>) -> Void)
}

public enum NetworkClientError: Error {
    case unknownError
}

public final class DefaultNetworkClient: NetworkClient {
    
    private let session: URLSession
    
    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        session = URLSession(configuration: config)
    }
    
    public func makeRequest<T: APIRequest>(_ request: T,
                                           responseQueue: DispatchQueue,
                                           completion: @escaping (Result<T.Response, Error>) -> Void) {
        let cachedResponse = session.configuration.urlCache?.cachedResponse(for: request.urlRequest)
        session.dataTask(with: request.urlRequest) { data, _, error in
            let decoder = JSONDecoder()
            if let data = data ?? cachedResponse?.data {
                do {
                    let object = try decoder.decode(T.Response.self, from: data)
                    responseQueue.async {
                        completion(.success(object))
                    }
                } catch {
                    responseQueue.async {
                        completion(.failure(error))
                    }
                }
            } else {
                responseQueue.async {
                    completion(.failure(error ?? NetworkClientError.unknownError))
                }
            }
        }.resume()
    }
    
}
