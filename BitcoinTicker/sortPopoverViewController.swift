//
//  sortPopoverViewController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 12/01/2018.
//  Copyright © 2018 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class SortPopoverViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var sortableOptions = ["Mrkcap", "price", "change"]
    let textCellIdentifier = "TextCell"
    
    override func viewDidLoad() {
//        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortableOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = CryptocurrencyTableViewCell(style: .value1, reuseIdentifier: textCellIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = sortableOptions[row]
        
        
        
        
        // DetailLabel
        //let pris = cryptos[row].getThePrice(currency: "USD")
        
//        cell.detailTextLabel?.text = currencySymbol
        
        return cell
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
