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
    var localCurrency:String = ""
    
    var personalFavorites:[String]!
    let defaults = UserDefaults.standard
    
    var wantToOnlyShowFavoriteCurrencies:Bool = false
    
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
        
        // Get favorite only status
        wantToShowOnlyFavorites()
        
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
        wantToShowOnlyFavorites()
        getFavorites()
        
        self.tableView.reloadData()
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        print("Table of Currencies became active again! Update the prices!")
        wantToShowOnlyFavorites()
        cryptoController.updatePrice()
    }
    
    @objc func refreshPull() {
        print("Oppdater things!")
        cryptoController.updatePrice()
        refreshControl.endRefreshing()
    }
    
    
    
    
    // Function to decide whether or not to show favorites only
    func wantToShowOnlyFavorites(){
        
        // Find information about wanting to only show favorite
        if let favoritesOnly = self.defaults.object(forKey: "wantToShowOnlyFavorites") {
            wantToOnlyShowFavoriteCurrencies = favoritesOnly as! Bool
        }else{
            wantToOnlyShowFavoriteCurrencies = false
        }
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // Need to check if personalFavorites really has any favorites
        if personalFavorites.count == 0 || wantToOnlyShowFavoriteCurrencies{
            return 1
        }else{
            return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        var headerName = ""
        
        if wantToOnlyShowFavoriteCurrencies{
            headerName = "Favorites"
            return headerName
        }
        
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
        
        // If only favorites, show only them
        if wantToOnlyShowFavoriteCurrencies{
            rowCount = personalFavorites.count
            return rowCount
        }
        
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
        
        //var localCurrency = ""
        var localCurrencySymbol = ""
        if let currency = self.defaults.object(forKey: "selectedCurrency") {
            if let currencySymbol = self.defaults.object(forKey: "selectedCurrencySymbol") {
                // selectedCurrencySymbol
                localCurrency = (currency as? String)!
                localCurrencySymbol = currencySymbol as! String
            }
        }else{
            print("No currency selected - something went wrong")
            // DEFAULT TO USD!
            localCurrency = "USD"
            localCurrencySymbol = "$"
        }
        
        
        
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
                    detailCoin = cryptos[i].getThePrice(currency: localCurrency)
                    imageName = cryptos[i].baseAbbriviation
                }
            }
        }else{
            hasFavs = 0
        }
        
        
        
        
        // If section 1 show all other altcoins
        if !wantToOnlyShowFavoriteCurrencies{
            if section == hasFavs {
                nameCoin = cryptos[row].baseCurrency
                detailCoin = cryptos[row].getThePrice(currency: localCurrency)
                imageName = cryptos[row].baseAbbriviation
            }
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
            cell.detailTextLabel?.text = String(describing: pris) + localCurrencySymbol
            
        }
        
        // Add image to cell view
        let image = UIImage(named: imageName)
        cell.imageView?.image = image
        
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        
        let section = indexPath.section
        let row = indexPath.row
        
        // In altcoin section
        if section == 1 {
            print(section, cryptos[row].baseCurrency)
            self.performSegue(withIdentifier: "showCurrencyInfo", sender: cryptos[row])
        }
        
        // In favorite section
        if section == 0 {
            print(section, cryptos.index(where: { $0.baseAbbriviation == personalFavorites[row] })!)
            let theSender = cryptos[cryptos.index(where: { $0.baseAbbriviation == personalFavorites[row] })!]
            self.performSegue(withIdentifier: "showCurrencyInfo", sender: theSender)
        }
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCurrencyInfo"{
            print("Stemmer")
            var touchedRow = sender as! Cryptocurrency
            print(touchedRow.baseCurrency)
            let yourNextViewController = (segue.destination as! DetailCryptoViewController)
            
            yourNextViewController.coin = touchedRow.baseAbbriviation
            yourNextViewController.favoriteCurrency = localCurrency
            let backItem = UIBarButtonItem()
            backItem.title = "Cryptos"
            navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
            yourNextViewController.title = touchedRow.baseCurrency
        }
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
