//
//  TableOfCryptocurrenciesController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 19/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class TableOfCryptocurrencies: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    //let cryptos = ["Bitcoin", "Ripple", "Litecoin", "Dogecoin"]
    //var personalFavorites = ["BTC", "ETH", "ETC", "LTC"]
    let textCellIdentifier = "TextCell"
    var cryptos:[Cryptocurrency]!
    var cryptoController:CryptoController!
    var refreshControl: UIRefreshControl!
    var data:([String], [Cryptocurrency])!
    
    var personalFavorites:[String]!
    let defaults = UserDefaults.standard
    
    
    
    override func viewDidLoad() {
        let start = NSDate(); // <<<<<<<<<< Start time
        super.viewDidLoad()
        
        // Observer for the view when it becomes active
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(TableOfCryptocurrencies.refreshPull), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        cryptoController = CryptoController(tableController:self)
        cryptos = cryptoController.getCurrencies()
        
        // Get favorite coins
        getFavorites()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // TIMER END
        let end = NSDate();   // <<<<<<<<<<   end time
        let timeInterval: Double = end.timeIntervalSince(start as Date); // <<<<< Difference in seconds (double)
        print("Time to load viewDidLoad: \(timeInterval) seconds")
        
        
    }
    
    @objc override func viewDidAppear(_ animated: Bool) {
        print("Did become active")
        getFavorites()
        
        self.tableView.reloadData()
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        print("Table of Currencies became active again! Update the prices!")
        cryptoController.updatePrice()
    }
    
    @objc func refreshPull() {
        print("Oppdater things!")
        cryptoController.updatePrice()
        refreshControl.endRefreshing()
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // Need to check if personalFavorites really has any favorites
        if personalFavorites.count == 0 {
            return 1
        }else{
            return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        var headerName = ""
        
        
        if personalFavorites.count == 0 {
            headerName = "Altcoins"
            return headerName
        }
        
        if section == 0 {
            headerName = "Favorites"
        }
        if section == 1 {
            headerName = "Altcoins"
        }
        return headerName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return cryptos.count
        var rowCount = 0
        
        // If no favorites, only show Altcoins
        if personalFavorites.count == 0 {
            rowCount = cryptos.count
            return rowCount
        }
        
        
        if section == 0 {
            rowCount = personalFavorites.count
        }
        if section == 1 {
            rowCount = cryptos.count
        }
        return rowCount
    }
    
    func redrawView() -> Void {
        self.tableView.reloadData()
    }
    
    func reloadCurrencyList() -> Void {
        cryptoController.loadCurrencies()
        cryptos = cryptoController.getCurrencies()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        //let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let section = indexPath.section
        let row = indexPath.row
        
        var hasFavs = 1
        
        var nameCoin = ""
        var detailCoin = ""
        var imageName = ""
        // If section 0 show favorites
        
        if personalFavorites.count != 0 {
            if section == 0 {
                if let i = cryptos.index(where: { $0.baseAbbriviation == personalFavorites[row] }) {
                    print("Index: \(i)")
                    print(cryptos[i].baseAbbriviation)
                    nameCoin = cryptos[i].baseCurrency
                    detailCoin = cryptos[i].getThePrice(currency: "USD")
                    imageName = cryptos[i].baseAbbriviation
                }
            }
        }else{
            hasFavs = 0
        }
        
        
        
        
        // If section 1 show all other altcoins
        
        if section == hasFavs {
            nameCoin = cryptos[row].baseCurrency
            detailCoin = cryptos[row].getThePrice(currency: "USD")
            imageName = cryptos[row].baseAbbriviation
        }
        
        //print(indexPath)
        //cell.textLabel?.text = data[ip.row].baseCurrency
        cell.textLabel?.text = nameCoin
        
        // DetailLabel
        let pris = detailCoin
        
        // Checking what info is available on pris
        if pris == "Updating..." {
            cell.detailTextLabel?.text = pris
        }else{
            cell.detailTextLabel?.text = String(describing: pris) + "$"
        }
        
        // Add image to cell view
        let image = UIImage(named: imageName)
        cell.imageView?.image = image
        
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let section = indexPath.section
        let row = indexPath.row
        //print(section, cryptos[row])
    }
    
    func getFavorites() -> Void {
        if let favoriteCoins = defaults.object(forKey: "favoriteCoins") {
            
            personalFavorites = favoriteCoins as! [String]
            print("Favorites: ", personalFavorites)
            //userVersion = currentVersion as! Int
        }else{
            print("Something went wrong, no favorites is present.")
            personalFavorites = []
            //userVersion = -1
        }
    }
    
}
