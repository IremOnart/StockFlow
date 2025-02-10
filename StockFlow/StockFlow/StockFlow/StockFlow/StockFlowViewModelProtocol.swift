//
//  StockFlowViewModelProtocol.swift
//  StockFlow
//
//  Created by İrem Onart on 8.02.2025.
//

import Foundation

enum StockFlowViewModelChange {
    case startLoading
    case endLoading
    case success
    case didError
    case highlightRows(indexes: [Int])
    case updateRow(index: Int, direction: ArrowDirection)
}

enum ArrowDirection {
    case up
    case down
    case stable
}

protocol StockFlowViewModelProtocol {
    var changeHandler: ((StockFlowViewModelChange) -> Void)? { get set }
    var stocks: [Stock] { get }
    var stocksData: [StockData] { get }
    var arrowDirections: [String: ArrowDirection] { get set }
    var previousCloValues: [String: String] { get set }
    
    func fetchStocks()
    func fetchStockData()
    func checkForCloChange(for stockData: StockData) -> Bool
}
