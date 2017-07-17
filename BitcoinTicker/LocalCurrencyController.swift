//
//  SettingsController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 23/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class LocalCurrencyController: UITableViewController{
    
    
    var fiats = ["USD", "NOK", "SEK", "EUR", "GBP", "CNY", "JPY"]
    var symbols:[String:String] = ["USD" : "$", "NOK" : "kr", "SEK" : "kr", "EUR" : "€", "GBP" : "£", "CNY" : "¥", "JPY" : "¥"]
    var cryptos:[Cryptocurrency]!
    
    var selectedCurrency:String?
    var selectedIndexPath:IndexPath?
    var selectedRow:Int?
    var selectedSection:Int?
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fiats = fiats.sorted()
        
        
        
        // Observer for the view when it becomes active
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Need to fix indexPath to be saved as userdefault
        loadFavorite()
    }
    
    func loadFavorite(){
        // Default to USD
        if let currency = defaults.object(forKey: "selectedCurrency") {
            selectedCurrency = currency as? String
        }else{
            print("No currency selected - something went wrong")
            // DEFAULT TO USD!
            selectedCurrency = "USD"
            let row = fiats.index(of: selectedCurrency!)
            selectedIndexPath = IndexPath(row: row!, section: 0)
            tableView.reloadData()
            return
        }
        if let row = defaults.object(forKey: "selectedRow") {
            if let section = defaults.object(forKey: "selectedSection"){
                selectedIndexPath = IndexPath(row: row as! Int, section: section as! Int)
            }
            
        }else{
            print("No ip present - something went wrong")
            print("Will try to find indexPath")
            let row = fiats.index(of: selectedCurrency!)
            selectedIndexPath = IndexPath(row: row!, section: 0)
        }
    }
    
    
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fiats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        //let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = fiats[row]
        
        if fiats[indexPath.row] == selectedCurrency {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        
        
        // DetailLabel
        //let pris = cryptos[row].getThePrice(currency: "USD")
        let currencySymbol = symbols[fiats[indexPath.row]]
        cell.detailTextLabel?.text = currencySymbol
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        // this gets rid of the grey row selection.  You can add the delegate didDeselectRowAtIndexPath if you want something to happen on deselection
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // The selected currency is the same as the one stored.
        if fiats[indexPath.row] == selectedCurrency {
            print("Samme velges1")
            return
        }
        
        // toggle old one off and the new one on
        let newCell = tableView.cellForRow(at: indexPath)
        if newCell?.accessoryType == UITableViewCellAccessoryType.none {
            newCell?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        let oldCell = tableView.cellForRow(at: selectedIndexPath!)
        if oldCell?.accessoryType == UITableViewCellAccessoryType.checkmark {
            oldCell?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        selectedIndexPath = indexPath  // save the selected index path
        selectedCurrency = fiats[indexPath.row] // Save the selected currency
        
        let row = indexPath.row
        
        
        
        print(selectedCurrency!, " - ", selectedIndexPath!)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        // The selected currency is the same as the one stored.
        if fiats[indexPath.row] == selectedCurrency {
            print("Samme velges")
            return
        }
        
        // toggle old one off and the new one on
        let newCell = tableView.cellForRow(at: indexPath)
        if newCell?.accessoryType == UITableViewCellAccessoryType.none {
            newCell?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        let oldCell = tableView.cellForRow(at: selectedIndexPath!)
        if oldCell?.accessoryType == UITableViewCellAccessoryType.checkmark {
            oldCell?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        selectedIndexPath = indexPath  // save the selected index path
        selectedCurrency = fiats[indexPath.row] // Save the selected currency
        
        let row = indexPath.row
        //print(fiats[row])
        
        print(selectedCurrency!, " - ", selectedIndexPath!)
        // Need to save the indexes and other information
        defaults.set(selectedIndexPath?.row, forKey: "selectedRow")
        defaults.set(selectedIndexPath?.section, forKey: "selectedSection")
        defaults.set(selectedCurrency, forKey: "selectedCurrency")
        defaults.set(symbols[selectedCurrency!], forKey: "selectedCurrencySymbol")
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        print("Table of fiats became active again! Update!")
        loadFavorite()
        tableView.reloadData()
    }
}
