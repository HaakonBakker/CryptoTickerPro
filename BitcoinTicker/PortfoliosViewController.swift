//
//  PortfolioViewController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 14/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class PortfoliosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var allPortfolios:[Portfolio] = []
    var textCellIdentifier = "textCell"
    override func viewDidLoad() {
        print("Portfoliosview has been loaded")
    }
    
    @objc override func viewDidAppear(_ animated: Bool) {
        print("Portfolio View controller did appear again! Update the prices!")
        tableView.delegate = self
        tableView.dataSource = self
        reloadData()
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        print("Portfolio View controller became active again! Update the prices!")
        reloadData()
    }
    
    func reloadData() -> Void {
        print(allPortfolios.count)
        self.tableView.reloadData()
        //self.currencyButton.setTitle(portfolio?.getCostCurrency() , for: .normal)
    }
    
    func loadPortfolios(){
        // Here we will load the portfolios saved in Core Data, as well as getting the elements for each portfolio
        
    }
    
    
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // Need to check if portfolio is initialized
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return cryptos.count
        var rowCount = 0
        rowCount = allPortfolios.count
        print("Row count: \(rowCount)")
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as UITableViewCell
        print("UPDATING")
        cell.detailTextLabel?.textColor = UIColor.lightGray
        let section = indexPath.section
        let row = indexPath.row
        
        var portName = allPortfolios[row].name
        var cost = allPortfolios[row].cost
        
        cell.textLabel?.text = portName
        cell.detailTextLabel?.text = String(describing: cost)
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        // No need to programatically create this function since it works through the Storyboard.
        
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPortfolioSegue"{
            print("Stemmer")
            let editViewController = (segue.destination as! PortfolioEditViewController)
            var newPort = Portfolio(theName:"My Portfolio")
            editViewController.portfolio = newPort
            
            allPortfolios.append(newPort)
            /*
             
             toCurrencyView
            var touchedRow = sender as? CryptocurrencyTableViewCell
            print(touchedRow?.baseAbbreviation)
            let theSender = cryptos[cryptos.index(where: { $0.baseAbbriviation == touchedRow?.baseAbbreviation! })!]
            let yourNextViewController = (segue.destination as! DetailCryptoViewController)
            
            yourNextViewController.coin = (theSender.baseAbbriviation)
            yourNextViewController.favoriteCurrency = localCurrency
            let backItem = UIBarButtonItem()
            backItem.title = "Cryptos"
            navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
            yourNextViewController.title = theSender.baseCurrency
 */
        }
        
        if segue.identifier == "portfolioViewIdentifier"{
            print("Stemmer")
            let portViewController = (segue.destination as! PortfolioViewController)
            let indexPath = tableView.indexPathForSelectedRow
            let port = allPortfolios[(indexPath?.row)!]
            portViewController.title = port.name
            portViewController.portfolio = port
        }
    }
}
