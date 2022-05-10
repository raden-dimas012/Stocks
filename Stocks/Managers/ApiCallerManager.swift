//
//  ApiCaller.swift
//  Stocks
//
//  Created by Raden Dimas on 10/05/22.
//

import Foundation

final class ApiCallerManager {
    static let shared = ApiCallerManager()
    
    private struct Constants {
        static let apiKey = "c9ssm3aad3ib0ug310rg"
        static let sandboxApiKey = "sandbox_c9ssm3aad3ib0ug310s0"
        static let baseUrl = "https://finnhub.io/api/v1/"
        
    }
    
    private init() {
        
    }
    
    public func search(
        query: String,
        completion: @escaping (Result<SearchResponse, Error>) -> Void
    ) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
                
        request(url: url(for: .search, queryParams: ["q":safeQuery]), expecting: SearchResponse.self, completion: completion)
      
    }
    
    private enum Endpoint: String {
        case search
    }
    
    private enum ApiError: Error {
        case invalidUrl
        case noDataReturned
    }
    
    
    private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        
        for(name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        queryItems.append(.init(name: "token", value: Constants.apiKey))
    
        urlString += "?" + queryItems.map{ "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        
        debugPrint(urlString)
        
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(url: URL?, expecting: T.Type,completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(ApiError.invalidUrl))
            return
            
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(ApiError.noDataReturned))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

