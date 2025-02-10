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
        
        updateArrow(direction: arrowDirection)
        configureLabel(value1Label, for: selectedFirstDropDown, with: stockData)
        configureLabel(value2Label, for: selectedSecondDropDown, with: stockData)

        
    }
    
    private func configureLabel(_ label: UILabel, for dropdown: String, with stockData: StockData) {
        let value: String?
        var color: UIColor? = .white

        switch dropdown {
        case "Son":
            value = stockData.las
        case "%Fark":
            value = "%\(stockData.pdd ?? "")"
            color = isPositive(stockData.pdd) ? .green : .red
        case "Fark":
            value = stockData.ddi
            color = isPositive(stockData.ddi) ? .green : .red
        case "Düşük":
            value = stockData.low
        case "Yüksek":
            value = stockData.hig
        default:
            value = stockData.las
        }

        label.text = value
        label.textColor = color
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
