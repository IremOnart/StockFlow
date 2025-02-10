//
//  StockDataModel.swift
//  StockFlow
//
//  Created by İrem Onart on 8.02.2025.
//

import Foundation

struct StockDataResponse: Codable {
    let l: [StockData]?
    let z: String?
}

struct StockData: Codable {
    let tke: String?
    let clo: String?
    let pdd: String?
    let low: String?
    let las: String?
    let ddi: String?
    let hig: String?
}
