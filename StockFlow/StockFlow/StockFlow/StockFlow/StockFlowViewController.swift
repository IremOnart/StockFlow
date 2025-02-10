//
//  StockFlowViewController.swift
//  StockFlow
//
//  Created by İrem Onart on 8.02.2025.
//

import UIKit
import DropDown

class StockFlowViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var firstDropDownView: UIView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondDropDownView: UIView!
    @IBOutlet weak var secondLabel: UILabel!
    
    let dropDownfirst = DropDown()
    let dropDownsecond = DropDown()
    let dropDownValues = ["Son", "%Fark", "Fark", "Düşük", "Yüksek"]
    var selectedFirstField: String = "Son"
    var selectedSecondField: String = "%Fark"
    var stockUpdateTimer: Timer?
    var previousStocks: [StockData] = []
    var loader: UIActivityIndicatorView?
    private var viewModel: StockFlowViewModelProtocol = StockFlowViewModel()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchInitialData()
        setupTableView()
        attachViewModel()
        startTimer()
        setUpUI()
    }
    
    private func attachViewModel() {
        viewModel.changeHandler = { [weak self] change in
            guard let self else { return }
            switch change  {
            case .startLoading:
                self.showLoader()
            case .endLoading:
                self.hideLoader()
            case .didError:
                showErrorPopup(message: "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.")
            case .success:
                print("success")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .highlightRows(let indexes):
                DispatchQueue.main.async {
                    self.highlightRows(at: indexes)
                    self.tableView.reloadData()
                }
            case .updateRow(let index, let direction):
                let indexPath = IndexPath(row: index, section: 0)
                DispatchQueue.main.async { 
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            default:
                return
            }
        }
    }
    
    func setUpUI() {
        dropDownfirst.anchorView = firstDropDownView
        dropDownsecond.anchorView = secondDropDownView
        dropDownfirst.dataSource = dropDownValues
        dropDownsecond.dataSource = dropDownValues
        
        firstDropDownView.layer.cornerRadius = 7
        secondDropDownView.layer.cornerRadius = 7
        
        firstDropDownView.layer.borderWidth = 1
        secondDropDownView.layer.borderWidth = 1
        
        firstDropDownView.layer.borderColor = UIColor.white.cgColor
        secondDropDownView.layer.borderColor = UIColor.white.cgColor
        
        dropDownfirst.selectRow(at: 0)
        dropDownsecond.selectRow(at: 1)
        
        dropDownfirst.bottomOffset = CGPoint(x: 0, y:(dropDownfirst.anchorView?.plainView.bounds.height)!)
        dropDownfirst.topOffset = CGPoint(x: 0, y:-(dropDownfirst.anchorView?.plainView.bounds.height)!)
        
        dropDownsecond.bottomOffset = CGPoint(x: 0, y:(dropDownsecond.anchorView?.plainView.bounds.height)!)
        dropDownsecond.topOffset = CGPoint(x: 0, y:-(dropDownsecond.anchorView?.plainView.bounds.height)!)
        
        dropDownfirst.direction = .bottom
        dropDownsecond.direction = .bottom
        
        dropDownfirst.selectionAction = { [unowned self] (index: Int, item: String) in
            self.firstLabel.text = "\(dropDownValues[index]) ↓"
            selectedFirstField = dropDownValues[index]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        dropDownsecond.selectionAction = { [unowned self] (index: Int, item: String) in
            self.secondLabel.text = "\(dropDownValues[index]) ↓"
            selectedSecondField = dropDownValues[index]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "StockFlowTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "StockFlowTableViewCell")
    }
    
    private func fetchInitialData() {
        viewModel.fetchStocks()
    }
    
    private func startTimer() {
        stockUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.viewModel.fetchStockData()
        }
    }
    private func highlightRows(at indexes: [Int]) {
        DispatchQueue.main.async {
            for cell in self.tableView.visibleCells {
                if let indexPath = self.tableView.indexPath(for: cell), indexes.contains(indexPath.row) {
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
                    }) { _ in
                        UIView.animate(withDuration: 0.5) {
                            cell.backgroundColor = UIColor(red: 55/255, green: 51/255, blue: 48/255, alpha: 1.0)
                        }
                    }
                }
            }
        }
    }
    
    func showErrorPopup(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoader() {
        loader = UIActivityIndicatorView(style: .large)
        loader?.center = view.center
        loader?.startAnimating()
        view.addSubview(loader!)
    }
    
    func hideLoader() {
        loader?.stopAnimating()
        loader?.removeFromSuperview()
        loader = nil
    }
    
    @IBAction func showFirstDropDown(_ sender: Any) {
        dropDownfirst.show()
    }
    
    @IBAction func showSecondDropDown(_ sender: Any) {
        dropDownsecond.show()
    }
}

extension StockFlowViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.stocksData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockFlowTableViewCell", for: indexPath) as! StockFlowTableViewCell
        let stockData = viewModel.stocksData[indexPath.row]
        let stocks = viewModel.stocks[indexPath.row]
        let arrowDirection = viewModel.arrowDirections[stockData.tke ?? ""]
        cell.configure(with: stockData, stock: stocks, arrowDirection: arrowDirection, selectedFirstDropDown: self.selectedFirstField, selectedSecondDropDown: self.selectedSecondField)
        return cell
    }
}

