//
//  SearchResponse.swift
//  Stocks
//
//  Created by Raden Dimas on 10/05/22.
//

import Foundation

struct SearchResponse: Codable {
    
    let count: Int
    let result: [SearchResult]
    
}

struct SearchResult: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}


