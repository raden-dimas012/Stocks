//
//  NewsStory.swift
//  Stocks
//
//  Created by Raden Dimas on 11/05/22.
//

import Foundation


struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let id: Int
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
