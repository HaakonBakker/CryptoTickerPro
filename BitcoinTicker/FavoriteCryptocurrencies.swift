//
//  FavoriteCryptocurrencies.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 23/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class FavoriteCryptocurrencies: UITableViewController{
    
    
    //var cryptos = ["BTC", "ETH", "ETC", "LTC"]
    
    var currencyList:[String:Cryptocurrency] = [:]
    var currencies:[Cryptocurrency] = []
    
    var favorites:[String]?
    var testFav = ["BTC", "ETH", "ETC", "LTC"]
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loader = CurrencyLoader()
        currencyList = loader.getCurrencyList()
        
        currencies = loader.getCurrencies()
        currencies = currencies.sorted(by: { $0.baseCurrency < $1.baseCurrency })
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        if let favoriteCoins = defaults.object(forKey: "favoriteCoins") {
            
            favorites = favoriteCoins as! [String]
            print("Favorites: ", favorites)
            //userVersion = currentVersion as! Int
        }else{
            print("Something went wrong, no favorites is present.")
            favorites = []
            //userVersion = -1
        }
 
        
        
        setTheme()
        self.tableView.reloadData()
    }
    
    func setTheme(){
        if defaults.bool(forKey: "blackTheme" ){
            //            Black theme
            self.tableView.backgroundColor = UIColor.black
            
            self.tableView.separatorColor = #colorLiteral(red: 0.2510845065, green: 0.2560918033, blue: 0.2651863098, alpha: 1)
        }else{
            //            White theme
            self.tableView.backgroundColor = UIColor.white
            
            
            self.tableView.separatorColor = UIColor(white: 0.97, alpha: 1)
        }
    }
    
    
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        //let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        if defaults.bool(forKey: "blackTheme" ){
            //            Black theme
            cell.backgroundColor = UIColor.black
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.gray
            
            // Change the selected color of the cell when selected
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.2696416974, green: 0.2744067311, blue: 0.27892676, alpha: 1)
            cell.selectedBackgroundView = backgroundView
        }else{
            //            White theme
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.gray
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.selectedBackgroundView = backgroundView
        }
        
        let row = indexPath.row
        
        // Check if favorite
        if (favorites?.contains(currencies[row].baseAbbriviation))!  {
            cell.accessoryType = row == indexPath.row ? .checkmark : .checkmark
        }
        
        
        cell.textLabel?.text = currencies[row].baseCurrency
        
        // DetailLabel
        let base = currencies[row].baseAbbriviation
        cell.detailTextLabel?.text = base
        
        let image = UIImage(named: currencies[row].baseAbbriviation)
        cell.imageView?.image = image
        
        
        
        // Add image to cell view
        
        //let imageName = cryptos[row].baseAbbriviation
        
        //let image = UIImage(named: imageName)
        //cell.imageView?.image = image
        
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let row = indexPath.row
        print(currencies[row].baseCurrency)
    }
    /*
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
     let row = indexPath.row
     print(fiats[row])
     }
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        print(currencies[row].baseCurrency)
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
                favorites!.remove(at: (favorites?.index(of: currencies[row].baseAbbriviation)!)!)
                print(favorites)
                defaults.set(favorites, forKey: "favoriteCoins")
               // defaults.synchronize()
                print("Removed and synced")
            }
            else{
                cell.accessoryType = .checkmark
                favorites!.append(currencies[row].baseAbbriviation)
                defaults.set(favorites, forKey: "favoriteCoins")
                //defaults.synchronize()
                print("Added and synced")
            }
        }
        
    }
}
