//
//  sortPopoverViewController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 12/01/2018.
//  Copyright © 2018 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class SortPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var sortableOptions = ["Mrkcap", "Price", "24H Change %", "Name"]
    let textCellIdentifier = "TextCell"
    
    @IBOutlet var sortTableView: UITableView!
    let defaults = UserDefaults.standard
    var cryptoTableView:TableOfCryptocurrencies!
    
    
    
    
    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
        if defaults.bool(forKey: "blackTheme" ){
            self.view.backgroundColor = UIColor.black
            self.sortTableView.backgroundColor = UIColor.black
        }
        
        sortTableView.delegate = self
        sortTableView.dataSource = self
    }
    
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortableOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = CryptocurrencyTableViewCell(style: .value1, reuseIdentifier: textCellIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        if defaults.bool(forKey: "blackTheme" ){
            cell.backgroundColor = UIColor.black
            cell.textLabel?.textColor = UIColor.white
//            cell.nameLabel.textColor = UIColor.white
//            cell.priceLabel.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
            
            // Change the selected color of the cell when selected
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.2696416974, green: 0.2744067311, blue: 0.27892676, alpha: 1)
            cell.selectedBackgroundView = backgroundView
        }
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = sortableOptions[row]
        
        
        
        
        // DetailLabel
        //let pris = cryptos[row].getThePrice(currency: "USD")
        
//        cell.detailTextLabel?.text = currencySymbol
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let row = indexPath.row
        let option = sortableOptions[row]
        print(option)
        
        if cryptoTableView.selectedSortOption == option{
            
        }else{
            // Will reset highToLow if we choose another option
            cryptoTableView.highToLow = false
        }
        print(cryptoTableView.highToLow)
        if option == "Mrkcap"{
            // Should sort by mrkcap
            if cryptoTableView.highToLow{
                cryptoTableView.cryptos.sort { $0.getmrkcap() < $1.getmrkcap() }
                cryptoTableView.highToLow = false
                cryptoTableView.selectedSortOption = option
                cryptoTableView.sortBarButtonItem.title = "Mrkcap ↓"
            }else{
                cryptoTableView.cryptos.sort { $0.getmrkcap() > $1.getmrkcap() }
                cryptoTableView.highToLow = true
                cryptoTableView.selectedSortOption = option
                cryptoTableView.sortBarButtonItem.title = "Mrkcap ↑"
            }
            
        }
        
        if option == "Price"{
            // Should sort by mrkcap
            if cryptoTableView.highToLow{
                cryptoTableView.cryptos.sort { $0.getTheDoublePrice(currency: cryptoTableView.localCurrency) < $1.getTheDoublePrice(currency: cryptoTableView.localCurrency) }
                cryptoTableView.highToLow = false
                cryptoTableView.selectedSortOption = option
                cryptoTableView.sortBarButtonItem.title = "Price ↓"
            }else{
                cryptoTableView.cryptos.sort { $0.getTheDoublePrice(currency: cryptoTableView.localCurrency) > $1.getTheDoublePrice(currency: cryptoTableView.localCurrency) }
                cryptoTableView.highToLow = true
                cryptoTableView.selectedSortOption = option
                cryptoTableView.sortBarButtonItem.title = "Price ↑"
            }
        }
        
        if option == "24H Change %"{
            // Should sort by mrkcap
            if cryptoTableView.highToLow{
                cryptoTableView.cryptos.sort { $0.changeLast24h < $1.changeLast24h }
                cryptoTableView.highToLow = false
                cryptoTableView.selectedSortOption = option
                cryptoTableView.sortBarButtonItem.title = "24H Δ% ↓"
            }else{
                cryptoTableView.cryptos.sort { $0.changeLast24h > $1.changeLast24h }
                cryptoTableView.highToLow = true
                cryptoTableView.selectedSortOption = option
                cryptoTableView.sortBarButtonItem.title = "24H Δ% ↑"
            }
            
        }
        
        
        // This option is reversed so we get the ABC...XYZ version when we first sort
        if option == "Name"{
            // Should sort by mrkcap
            if cryptoTableView.highToLow{
                cryptoTableView.cryptos.sort { $0.baseCurrency > $1.baseCurrency }
                cryptoTableView.highToLow = false
                cryptoTableView.selectedSortOption = option
                cryptoTableView.sortBarButtonItem.title = "Name ↑"
            }else{
                cryptoTableView.cryptos.sort { $0.baseCurrency < $1.baseCurrency }
                cryptoTableView.highToLow = true
                cryptoTableView.selectedSortOption = option
                cryptoTableView.sortBarButtonItem.title = "Name ↓"
            }
            
        }
        
        cryptoTableView.tableView.reloadData()
        self.dismiss()
    }
    
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return .none
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: "dismiss")
        navigationController.topViewController?.navigationItem.rightBarButtonItem = btnDone
        return navigationController
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
