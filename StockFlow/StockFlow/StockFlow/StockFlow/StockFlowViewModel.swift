//
//  StockFlowViewModel.swift
//  StockFlow
//
//  Created by İrem Onart on 8.02.2025.
//

import Foundation

class StockFlowViewModel: StockFlowViewModelProtocol {
    var changeHandler: ((StockFlowViewModelChange) -> Void)?
    
    var stocks: [Stock] = []
    var columns: [ColumnOption] = []
    var stocksData: [StockData] = []
    var previousLasValues: [String: String] = [:]
    var arrowDirections: [String: ArrowDirection] = [:]
    var previousCloValues: [String: String] = [:]
    
    func fetchStocks() {
        self.emit(change: .startLoading)
        NetworkManager.shared.fetchStocks { [weak self] stocks in
            self?.emit(change: .endLoading)
            guard let self = self else {
                return
            }
            
            if let stocks = stocks {
                self.stocks = stocks.mypageDefaults ?? []
                self.columns = stocks.mypage ?? []
                self.emit(change: .success)
            } else {
                self.stocks = []
                self.emit(change: .didError)
            }
        }
    }
    
    func fetchStockData() {
        let stockKeys = stocks.compactMap { $0.tke }
        let columnKey = columns.compactMap { $0.key }

        NetworkManager.shared.fetchStockData(stockKeys: stockKeys, fields: columnKey) { [weak self] updatedStocks in
            self?.emit(change: .endLoading)
            guard let self = self else {
                return
            }
            
            guard let updatedStocks = updatedStocks else {
                self.emit(change: .didError)
                return
            }

            var changedIndexes: [Int] = []
            self.stocksData = updatedStocks
            for (index, stockData) in updatedStocks.enumerated() {
                self.updateArrowDirection(for: stockData)
                
                if self.checkForCloChange(for: stockData) {
                    changedIndexes.append(index)
                }
            }
            
            if !changedIndexes.isEmpty {
                self.emit(change: .highlightRows(indexes: changedIndexes))
            }
            self.emit(change: .success)
        }
    }
    
    private func updateArrowDirection(for stockData: StockData) {
        guard let previousLas = previousLasValues[stockData.tke ?? ""] else {
            let key = stockData.tke ?? ""
            arrowDirections[key] = .stable
            previousLasValues[key] = (stockData.las ?? "").isEmpty ? "0" : stockData.las
            return
        }

        let newLas = stockData.las
        let previousLasValue = convertToDouble(previousLas)
        let newLasValue = convertToDouble(newLas ?? "")

        guard newLasValue != previousLasValue else {
            return
        }

        let newDirection: ArrowDirection = newLasValue > previousLasValue ? .up : .down

        previousLasValues[stockData.tke ?? ""] = newLas
        arrowDirections[stockData.tke ?? ""] = newDirection

        if let index = stocksData.firstIndex(where: { $0.tke == stockData.tke }) {
            emit(change: .updateRow(index: index, direction: newDirection))
        } else {
            print("Hata: stockData.tke (\(stockData.tke)) için index bulunamadı.")
        }
    }


    private func convertToDouble(_ value: String) -> Double {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.numberStyle = .decimal
        
        guard let number = formatter.number(from: value) else {
            print("Hata: \(value) sayıya çevrilemedi.")
            return 0
        }
        
        return number.doubleValue
    }


    
    func checkForCloChange(for stockData: StockData) -> Bool {
        guard let previousClo = previousCloValues[stockData.tke ?? ""] else {
            previousCloValues[stockData.tke ?? ""] = stockData.clo
            return false
        }
        
        if stockData.clo != previousClo {
            previousCloValues[stockData.tke ?? ""] = stockData.clo
            return true
        }
        
        return false
    }
    
    private func emit(change: StockFlowViewModelChange) {
        changeHandler?(change)
    }
}
