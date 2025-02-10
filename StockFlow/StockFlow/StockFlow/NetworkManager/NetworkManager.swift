//
//  NetworkManager.swift
//  StockFlow
//
//  Created by İrem Onart on 8.02.2025.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func fetchStocks(completion: @escaping (StockResponse?) -> Void) {
        let url = "https://sui7963dq6.execute-api.eu-central-1.amazonaws.com/default/ForeksMobileInterviewSettings"
        
        AF.request(url).responseDecodable(of: StockResponse.self) { response in
            switch response.result {
            case .success(let stockResponse):
                print("Stocks fetched successfully")
                completion(stockResponse)
            case .failure(let error):
                print("Network error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    func fetchStockData(stockKeys: [String], fields: [String], completion: @escaping ([StockData]?) -> Void) {
        let fieldsString = fields.joined(separator: ",")
        let stockKeysString = stockKeys.joined(separator: "~")
        
        guard let encodedFields = fieldsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedStockKeys = stockKeysString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }
        
        let urlString = "https://sui7963dq6.execute-api.eu-central-1.amazonaws.com/default/ForeksMobileInterview?fields=\(encodedFields)&stcs=\(encodedStockKeys)"
        
        AF.request(urlString).responseDecodable(of: StockDataResponse.self) { response in
            switch response.result {
            case .success(let stockDataResponse):
                print("Stock data fetched successfully")
                completion(stockDataResponse.l)
            case .failure(let error):
                print("Network error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
