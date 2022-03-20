//
//  NasaApodRequest.swift
//  NetworkLayer
//
//  Created by Ivan Reinaldo on 3/20/22.
//

import Foundation
import NetworkLayer

struct NasaApodRequest: APIRequest {
        
    typealias Response = ResponseModel
    
    init(date: Date? = nil) {
        self.date = date
    }
    
    private let date: Date?
    
    var urlRequest: URLRequest {
        let apiKey = "yxdLHmlleYUSsJwIOA4YrXBRzLCwigmkUFPIg7j5"
        let url: String
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            let dateString = formatter.string(from: date)
            url = "https://api.nasa.gov/planetary/apod?api_key=\(apiKey)&date=\(dateString)"
        } else {
            url = "https://api.nasa.gov/planetary/apod?api_key=\(apiKey)"
        }
        let request = URLRequest(url: URL(string: url)!)
        return request
    }
    
    struct ResponseModel: Codable {
        let title: String
        let explanation: String
        let url: URL
        let mediaType: MediaType
        let date: Date

        enum MediaType: String, Codable {
            case image = "image"
            case video = "video"
        }
        
        enum CodingKeys: String, CodingKey {
            case mediaType = "media_type"
            case title, explanation, url, date
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            explanation = try container.decode(String.self, forKey: .explanation)
            url = try container.decode(URL.self, forKey: .url)
            mediaType = try container.decode(MediaType.self, forKey: .mediaType)
            let dateString = try container.decode(String.self, forKey: .date)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
                self.date = date
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.date],
                                                        debugDescription: "incorrect date format: \(dateString)",
                                                        underlyingError: nil))
            }
        }
    }
}
