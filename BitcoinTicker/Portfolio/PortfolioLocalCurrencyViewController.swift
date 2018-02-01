//
//  PortfolioLocalCurrency.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 17/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class PortfolioLocalCurrencyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var localCurrencies:LocalCurrencies?
    var textCellIdentifier = "textCell"
    var selectedCurrency:String?
    var selectedIndexPath:IndexPath?
    var portfolio:Port?
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        localCurrencies = LocalCurrencies()
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        loadChosenCurrency()
        tableView.delegate = self
        tableView.dataSource = self
        print("PortfolioLocalCurrencyViewController has been loaded")
        setTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setTheme()
    }
    
    func setTheme(){
        if defaults.bool(forKey: "blackTheme" ){
            tableView.backgroundColor = .black
        }else{
            tableView.backgroundColor = .white
        }
    }
    
    
    
    
    func loadChosenCurrency(){
        // Default to USD
        
        if let currency = portfolio?.costCurrency {
            // There is a costCurrency present
            selectedCurrency = currency
            print(selectedCurrency)
            
            let row = localCurrencies?.fiats.index(of: selectedCurrency!)
            selectedIndexPath = IndexPath(row: row!, section: 0)
        }else{
            // Nothing is selected, default to user default
            if let currency = defaults.object(forKey: "selectedCurrency") {
                selectedCurrency = currency as? String
            }else{
                // Default to USD
                selectedCurrency = "USD"
                
            }
            let row = localCurrencies?.fiats.index(of: selectedCurrency!)
            selectedIndexPath = IndexPath(row: row!, section: 0)
        }
        tableView.reloadData()
        return
    }
    
    
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // Need to check if portfolio is initialized
        if let p = localCurrencies{
            return 1
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return cryptos.count
        var rowCount = 0
        if let l = localCurrencies{
            rowCount = l.getFiats().count
        }
        print("Row count: \(rowCount)")
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        cell.detailTextLabel?.textColor = UIColor.lightGray
        let section = indexPath.section
        let row = indexPath.row
        
        var currencyName = localCurrencies?.getFiat(number: row)
        var currencySymbol = localCurrencies?.getSymbol(currency: currencyName!)
        
        
        cell.textLabel?.text = currencyName
        cell.detailTextLabel?.text = currencySymbol
        
        
        // Need to check if the currency needs a checkmark
        if localCurrencies?.getFiat(number: row) == selectedCurrency {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        if defaults.bool(forKey: "blackTheme" ){
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white
            
            // Change the selected color of the cell when selected
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.2696416974, green: 0.2744067311, blue: 0.27892676, alpha: 1)
            cell.selectedBackgroundView = backgroundView
            
        }else{
            cell.textLabel?.textColor = .black
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.selectedBackgroundView = backgroundView
        }
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        // The selected currency is the same as the one stored.
        if localCurrencies?.getFiat(number: indexPath.row) == selectedCurrency {
            print("Samme velges")
            return
        }
        
        // toggle old one off and the new one on
        let newCell = tableView.cellForRow(at: indexPath)
        if newCell?.accessoryType == UITableViewCellAccessoryType.none {
            newCell?.accessoryType = UITableViewCellAccessoryType.checkmark
            // Add the currency to the portfolio
            portfolio?.costCurrency = localCurrencies?.getFiat(number: indexPath.row)
            print("Portfolio cost currency added")
            print(portfolio?.costCurrency)
        }
        let oldCell = tableView.cellForRow(at: selectedIndexPath!)
        if oldCell?.accessoryType == UITableViewCellAccessoryType.checkmark {
            oldCell?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        selectedIndexPath = indexPath  // save the selected index path
        selectedCurrency = localCurrencies?.getFiat(number: indexPath.row) // Save the selected currency
        
        let row = indexPath.row
        //print(fiats[row])
        
        print(selectedCurrency!, " - ", selectedIndexPath!)
    }
}
