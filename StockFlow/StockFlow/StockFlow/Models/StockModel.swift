//
//  StockModel.swift
//  StockFlow
//
//  Created by İrem Onart on 8.02.2025.
//

import Foundation

struct StockResponse: Codable {
    let mypageDefaults: [Stock]?
    let mypage: [ColumnOption]?
}

struct Stock: Codable {
    let cod: String?
    let gro: String?
    let tke: String?
    let def: String?
    var las: Double?
}

struct ColumnOption: Codable {
    let name: String?
    let key: String?
}
