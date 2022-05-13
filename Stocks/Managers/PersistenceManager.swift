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
        static let onboardedKey = "hasOnBoarded"
        static let watchlist = "watchlist"
    }
    
    private init() {}
    
    public var watchlist: [String] {
        if !hasOnBoarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlist) ?? []
    }
    
    public func watchlistContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }
    
    public func addToWatchlist(symbol: String,companyName: String) {
        var current = watchlist
        current.append(symbol)
        
        userDefaults.set(current, forKey: Constants.watchlist)
        
        userDefaults.set(companyName, forKey: symbol)
        
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    public func removeFromWatchlist(symbol: String) {
        var newList = [String]()
        
//        debugPrint("Deleting: \(symbol)")
        
        userDefaults.set(nil, forKey: symbol)
        
        for item in watchlist where item != symbol {
//            debugPrint("\n \(item)")
//            DispatchQueue.main.async {
                newList.append(item)
//            }
        }
        
        userDefaults.set(newList, forKey: Constants.watchlist)
    }
    
    
    private var hasOnBoarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    private func setUpDefaults() {
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft Corporation",
            "SNAP": "Snap Inc.",
            "GOOG": "Alphabet",
            "AMZN": "Amazon.com, Inc.",
//            "WORK": "Slack Technologies",
            "FB": "Facebook Inc.",
            "NVDA": "Nvidia Inc.",
            "NKE": "Nike",
            "PINS": "Pinterest Inc."
        ]
        
        let symbols = map.keys.map{ $0 }
        
        userDefaults.set(symbols, forKey: Constants.watchlist)
        
        for (symbol, name) in map {
            userDefaults.set(name,forKey: symbol)
        }
    }
    
}
