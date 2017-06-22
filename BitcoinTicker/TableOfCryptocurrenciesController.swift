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
    let textCellIdentifier = "TextCell"
    var cryptos:[Cryptocurrency]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cryptoController = CryptoController(tableController:self)
        cryptos = cryptoController.getCurrencies()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        // This is a test.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(cryptos.count)
        return cryptos.count
    }
    
    func redrawView() -> Void {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        //let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = cryptos[row].baseCurrency
        
        // DetailLabel
        let pris = cryptos[row].getThePrice(currency: "USD")
        cell.detailTextLabel?.text = String(describing: pris) + "$"
        
        
        
        
        // Add image to cell view
        /*
        let imageName = "House.png"
        let image = UIImage(named: imageName)
        cell.imageView?.image = image
        */
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let row = indexPath.row
        print(cryptos[row])
    }
}
