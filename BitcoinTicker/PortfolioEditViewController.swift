//
//  PortfolioEditViewController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 17/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class PortfolioEditViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var costCurrencyLabel: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameOfPortfolioLabel: UITextField!

    var portfolio:Portfolio?
    let formatter = NumberFormatter()
    var textCellIdentifier = "textCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        
        self.hideKeyboardWhenTappedAround()
        
        self.nameOfPortfolioLabel.text = portfolio?.name
        self.costCurrencyLabel.text = portfolio?.getCostAsString()
       
        self.nameOfPortfolioLabel.inputAccessoryView = addDoneButtonOverKeyboard()
        self.costCurrencyLabel.inputAccessoryView = addDoneButtonOverKeyboard()
        
        self.currencyButton.setAttributedTitle(getNSAttributedString(), for: .normal)
        //self.currencyButton.setTitle(portfolio?.getCostCurrency() , for: .normal)
        
        //self.currencyButton.setTitle("HELLO()" , for: .normal)
        createTestElements()
        
        tableView.delegate = self
        tableView.dataSource = self
        print("Portfolio Edit view has been loaded")
    }
    
    func getNSAttributedString() -> NSAttributedString {
        var myString = portfolio?.getCostCurrency() 
        let myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.blue ]
        let myAttrString = NSAttributedString(string: myString!, attributes: myAttribute)
        return myAttrString
    }
    
    @objc override func viewDidAppear(_ animated: Bool) {
        print("Portfolio editview did appear again! Update the prices!")
        reloadData()
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        print("Portfolio editview became active again! Update the prices!")
        reloadData()
    }
    
    func reloadData() -> Void {
        print(portfolio)
        print(portfolio?.costCurrency)
        self.currencyButton.setAttributedTitle(getNSAttributedString(), for: .normal)
        //self.currencyButton.setTitle(portfolio?.getCostCurrency() , for: .normal)
    }
    
    func createTestElements(){
        let el1 = Element()
        let el2 = Element()
        let el3 = Element()
        let el4 = Element()
        
        el1.currency = "BTC"
        el1.amount = 23.5
        
        el2.currency = "BTC"
        el2.amount = 0.13
        
        el3.currency = "DASH"
        el3.amount = 3.5
        
        el4.currency = "XMR"
        el4.amount = 35.5
        
        portfolio?.assets.append(el1)
        portfolio?.assets.append(el2)
        portfolio?.assets.append(el3)
        portfolio?.assets.append(el4)
        
    }
    
    func savePortfolio(){
        
        if let name = self.nameOfPortfolioLabel.text, let cost = self.costCurrencyLabel.text?.doubleValue {
            portfolio?.name = name
            portfolio?.cost = cost
            print("Saved the portfolio - name: \(String(describing: portfolio?.name)) -- cost: \(String(describing: portfolio?.cost))")
        }else{
            print("Cannot save, something is not correct.")
        }
    }
    
    @objc func doneButtonAction() {
        savePortfolio()
        self.view.endEditing(true)
    }
    
    func addDoneButtonOverKeyboard() -> UIToolbar{
        // Add done button over keyboard
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        return toolbar
    }
    
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // Need to check if portfolio is initialized
        if let p = portfolio{
            return 1
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return cryptos.count
        var rowCount = 0
        if let p = portfolio{
            rowCount = p.assets.count
        }
        print("Row count: \(rowCount)")
        return rowCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        cell.detailTextLabel?.textColor = UIColor.lightGray
        let section = indexPath.section
        let row = indexPath.row
        
        var cur = portfolio?.assets[row].getName()
        var amount = portfolio?.assets[row].getAmount()
        if let a = amount {
            cell.detailTextLabel?.text = String(describing: a)
        }
        print(amount)
        cell.textLabel?.text = cur
        
        
        
        // Add image
        let image = UIImage(named: cur!)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCurrencyView"{
            print("Stemmer")
            let localCurrencyViewController = (segue.destination as! PortfolioLocalCurrencyViewController)
            //var newPort = Portfolio(theName:"My Portfolio")
            localCurrencyViewController.portfolio = portfolio
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
    }
    
}

extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}

// Put this piece of code anywhere you like
extension PortfolioEditViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PortfolioEditViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        savePortfolio()
        view.endEditing(true)
    }
}
