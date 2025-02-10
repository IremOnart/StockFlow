//
//  StockFlowTableViewCell.swift
//  StockFlow
//
//  Created by İrem Onart on 8.02.2025.
//

import UIKit

class StockFlowTableViewCell: UITableViewCell {
    @IBOutlet private weak var symbolLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var value1Label: UILabel!
    @IBOutlet private weak var value2Label: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func configure(with stockData: StockData, stock: Stock, arrowDirection: ArrowDirection?, selectedFirstDropDown: String, selectedSecondDropDown: String) {
        symbolLabel.text = stock.cod
        timeLabel.text = stockData.clo
        value1Label.textColor = .white
        value2Label.textColor = .white
        
        updateArrow(direction: arrowDirection)
        
        switch selectedFirstDropDown {
        case "Son":
            value1Label.text = stockData.las
        case "%Fark":
            value1Label.text = "%\(stockData.pdd ?? "")"
            value1Label.textColor = isPositive(stockData.pdd) ? .green : .red
        case "Fark":
            value1Label.text = stockData.ddi
            value1Label.textColor = isPositive(stockData.ddi) ? .green : .red
        case "Düşük":
            value1Label.text = stockData.low
        case "Yüksek":
            value1Label.text = stockData.hig
        default:
            value1Label.text = stockData.las
        }
        
        switch selectedSecondDropDown {
        case "Son":
            value2Label.text = stockData.las
        case "%Fark":
            value2Label.text = "%\(stockData.pdd ?? "")"
            value2Label.textColor = isPositive(stockData.pdd) ? .green : .red
        case "Fark":
            value2Label.text = stockData.ddi
            value2Label.textColor = isPositive(stockData.ddi) ? .green : .red
        case "Düşük":
            value2Label.text = stockData.low
        case "Yüksek":
            value2Label.text = stockData.hig
        default:
            value2Label.text = stockData.las
        }
        
    }
    
       func updateArrow(direction: ArrowDirection?) {
           switch direction {
           case .up:
               arrowImageView.image = UIImage(systemName: "arrow.up")
               arrowImageView.tintColor = .green
           case .down:
               arrowImageView.image = UIImage(systemName: "arrow.down")
               arrowImageView.tintColor = .red
           case .stable?, nil:
               arrowImageView.image = nil
           }
       }
       
    
    private func isPositive(_ pdd: String?) -> Bool {
        guard let pdd = pdd else { return false }
        let cleanedPdd = pdd.replacingOccurrences(of: ",", with: ".")
        if let pddValue = Double(cleanedPdd) {
            return pddValue >= 0
        }
        return false
    }
}
