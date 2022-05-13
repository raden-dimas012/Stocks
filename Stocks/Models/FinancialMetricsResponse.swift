//
//  FinancialMetricResponse.swift
//  Stocks
//
//  Created by Raden Dimas on 13/05/22.
//

import Foundation

struct FinancialMetricsResponse: Codable {
    
    let metric: Metrics
    
}

struct Metrics: Codable {
    let tenDayAverageTradingVolume: Float
    let annualWeekHigh: Double
    let annualWeekLow: Double
    let annualWeekLowDate: String
    let annualPriceReturnDaily: Double
    let beta: Float
    
    enum CodingKeys: String, CodingKey {
        case tenDayAverageTradingVolume = "10DayAverageTradingVolume"
        case annualWeekHigh = "52WeekHigh"
        case annualWeekLow = "52WeekLow"
        case annualWeekLowDate = "52WeekLowDate"
        case annualPriceReturnDaily = "52WeekPriceReturnDaily"
        case beta = "beta"
    }
}
