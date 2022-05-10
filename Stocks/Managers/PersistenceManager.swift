//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Raden Dimas on 10/05/22.
//

import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        
    }
    
    private init() {}
    
    public var watchlist: [String] {
        return []
    }
    
    public func addToWatchlist() {
        
    }
    
    public func removeFromWatchlist() {
        
    }
    
    
    private var hasOnBoarded: Bool {
        return false
    }
    
}
