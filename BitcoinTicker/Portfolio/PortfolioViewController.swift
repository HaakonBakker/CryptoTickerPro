//
//  PortfolioViewController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 17/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class PortfolioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    var portfolio:Port?
    @IBOutlet weak var tableView: UITableView!
    let textCellIdentifier:String = "TextCell"
    
    // Labels in the view
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var profitPercentageLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    
    var portfolioController:PortfolioController!
    var portfolioCalculations:PortfolioCalculations!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        
        if let port = portfolio {
            portfolioCalculations = PortfolioCalculations(port: port)
            updateLabels(port: port)
        }
        print("The current value of this Portfolio:" + String(describing: portfolioCalculations.calculateCurrentValue()))
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        print("Portfolioview has been loaded")
        tableView.delegate = self
        tableView.dataSource = self
        portfolioController = PortfolioController.shared()
        // Testing portfoliocontroller
        //let pCon = PortfolioController()
    }
    
    func updateLabels(port:Port){
        // Need to get the local symbol
        var localCurrencySymbol = ""
        if let currencySymbol = self.defaults.object(forKey: "selectedCurrencySymbol") {
            localCurrencySymbol = currencySymbol as! String
        }else{
            print("No currency selected - something went wrong")
            localCurrencySymbol = "$"
        }
        
        // Need to get the costCurrencySymbol
        var localCurrencies = LocalCurrencies()
        var costSymbol = localCurrencies.getSymbol(currency: port.costCurrency!)
        
        
        var curValue = String(describing: portfolioCalculations.getCurrentValueWithTwoDecimal())
        var cost = String(format: "%.2f", port.cost)
        
        print("\(curValue) <- Cur val ---)")
        
        currentValueLabel.text = curValue + localCurrencySymbol
        costLabel.text = cost + costSymbol
        

        
        // Need to convert the costValue to the localValue
        var fiatCur = FiatCurrency.sharedInstance
        
        fiatCur.getConversionRate(fsym: port.costCurrency!, rate: { (success) -> Void in
            print(success)
            // We have the currency rate
            var rate = success
            var rateDouble = Double(success)
            
            // Need the cost
            var portfolioCost = port.cost
            
            // Find the cost in the local Value
            var costInLocalValue = portfolioCost * rateDouble
            
            
            var currentValueDouble = Double(self.portfolioCalculations.getCurrentValueWithTwoDecimal())!
            // Calculate the profit
            var profit = currentValueDouble - costInLocalValue
            
            // Calculate the percentage profit
            var percentProfit = (currentValueDouble - costInLocalValue)/currentValueDouble*100
            
            // Update the UI in the main queue
            DispatchQueue.main.async{
                // Need to fix the colors depending on profit or not
                
                // Set color based on positive or negative
                if (profit > 0){
                    // Positive change
                    self.profitLabel.textColor = UIColor(red: 0, green: 0.733, blue: 0.153, alpha: 1)
                    self.profitPercentageLabel.textColor = UIColor(red: 0, green: 0.733, blue: 0.153, alpha: 1)
                    
                }else{
                    // Negative change
                    self.profitLabel.textColor = UIColor(red: 0.996, green: 0.125, blue: 0.125, alpha: 1)
                    self.profitPercentageLabel.textColor = UIColor(red: 0.996, green: 0.125, blue: 0.125, alpha: 1)
                    
                }
                
                self.profitLabel.text = String(describing: profit) + localCurrencySymbol
                self.profitPercentageLabel.text = String(format: "%.2f", percentProfit) + "%"
            }

        })
        
    }
    
    
    @objc override func viewDidAppear(_ animated: Bool) {
        print("Portfolio View controller did appear again! Update the prices!")
        portfolioController.updateStatus()
        reloadData()
        self.updateLabels(port: portfolio!)
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        print("Portfolio View controller became active again! Update the prices!")
        reloadData()
        self.updateLabels(port: portfolio!)
    }
    
    func reloadData() -> Void {
        
        self.title = portfolio!.name
        self.tableView.reloadData()
        //self.currencyButton.setTitle(portfolio?.getCostCurrency() , for: .normal)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPortfolio"{
            print("StemmertilEditPortfolio")
            let editViewController = (segue.destination as! PortfolioEditViewController)
            editViewController.portfolio = portfolio
            editViewController.portfolioViewController = self
            
        }
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // Need to check if portfolio is initialized
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return cryptos.count
        var rowCount = 0
        if let p = portfolio{
            rowCount = (p.elementRelationship?.count)!
        }
        print("Row count: \(rowCount)")
        return rowCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        cell.detailTextLabel?.textColor = UIColor.lightGray
        let section = indexPath.section
        let row = indexPath.row
        
        let elArr = portfolio?.elementRelationship
        let myArr = Array(elArr!) as! [El]
        
        var cur = ""
        if let currency = myArr[row].currency{
            cur = currency
        }
        
        
        var amount = myArr[row].amount
        
        cell.detailTextLabel?.text = String(describing: amount)
        print(amount)
        cell.textLabel?.text = cur
        
        
        
        // Add image
        let image = UIImage(named: cur)
        cell.imageView?.image = image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        var headerName = ""
        
        if section == 0 {
            headerName = "Assets"
        }
        
        return headerName
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        // No need to programatically create this function since it works through the Storyboard.
        
    }
}
