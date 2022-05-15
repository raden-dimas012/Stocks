//
//  StocksTests.swift
//  StocksTests
//
//  Created by Raden Dimas on 15/05/22.
//

@testable import Stocks

import XCTest

class StocksTests: XCTestCase {

    func testSomething() {
        let number = 1
        let string = "1"
        XCTAssertEqual(number, Int(string), "Numbers do not match")
    }
    
    func testCandleStickDataConversion() {
        let doubles: [Double] = Array(repeating: 12.2, count: 10)
        var timeStamps: [TimeInterval] = []
        
        for x in 0..<12 {
            let interval = Date().addingTimeInterval(3600 * TimeInterval(x)).timeIntervalSince1970
            
            timeStamps.append(interval)
        }
        
        timeStamps.shuffle()
        
        let marketData = MarketDataResponse(
            open: doubles,
            close: doubles,
            high: doubles,
            low: doubles,
            status: "success",
            timestamps: timeStamps)
        
        let candleSticks = marketData.candleStick
        XCTAssertEqual(candleSticks.count, marketData.open.count)
        XCTAssertEqual(candleSticks.count, marketData.close.count)
        XCTAssertEqual(candleSticks.count, marketData.high.count)
        XCTAssertEqual(candleSticks.count, marketData.low.count)
        XCTAssertEqual(candleSticks.count, marketData.timestamps.count)
        
        let dates = candleSticks.map({ $0.date })
        for x in 0..<dates.count-1 {
            let current = dates[x]
            let next = dates[x+1]
            
            XCTAssertTrue(current < next, "\(current) date should be greater than \(next) date)
        }
        
      
        
    }
    
    
    
    
    
}
