//
//  AddAsset.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 04/08/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddAsset: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let defaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    var currencyList:[String:Cryptocurrency] = [:]
    var currencies:[Cryptocurrency] = []
    var asset:El?
    
    var selectedIndexPath:IndexPath?
    var selectedRow:Int?
    var selectedSection:Int?
    
    //var arrayOfAssets:[El]
    
    @IBOutlet weak var amountLabel: UITextField!
    @IBOutlet var amountStaticLabel: UILabel!
    
    
    
    var portfolioEditViewController:PortfolioEditViewController?
    
    override func viewDidLoad() {
        // Text input done button setup
        self.hideKeyboardWhenTappedAround()
        self.amountLabel.inputAccessoryView = addDoneButtonOverKeyboard()
        if let theAsset = asset{
            self.amountLabel.text = String(describing: theAsset.amount)
            
        }
        
        // If the amount label is 0.0 then it should be nothing in order to speed up the time it takes to edit the asset.
        if self.amountLabel.text == "0.0"{
            self.amountLabel.text = ""
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        print("AddAssetView has been loaded")
        let loader = CurrencyLoader()
        currencyList = loader.getCurrencyList()
        
        currencies = loader.getCurrencies()
        currencies = currencies.sorted(by: { $0.baseCurrency < $1.baseCurrency })
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        self.amountLabel.becomeFirstResponder()
        
        
        
        setTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setTheme()
    }
    
    func setTheme(){
        if defaults.bool(forKey: "blackTheme" ){
            tableView.backgroundColor = .black
            view.backgroundColor = .black
            amountLabel.textColor = .white
            amountStaticLabel.textColor = .white
        }else{
            tableView.backgroundColor = .white
            view.backgroundColor = .white
            amountLabel.textColor = .black
            amountStaticLabel.textColor = .black
        }
    }

    
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        //let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        
        let row = indexPath.row
        /*
        // Check if favorite
        if (favorites?.contains(currencies[row].baseAbbriviation))!  {
            cell.accessoryType = row == indexPath.row ? .checkmark : .checkmark
        }
        */
        
        if currencies[row].baseAbbriviation == asset?.currency {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        cell.textLabel?.text = currencies[row].baseCurrency
        
        // DetailLabel
        let base = currencies[row].baseAbbriviation
        cell.detailTextLabel?.text = base
        
        if let image = UIImage(named: currencies[row].baseAbbriviation){
            cell.imageView?.image = image
        }
        

        
        if defaults.bool(forKey: "blackTheme" ){
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white
            
            // Change the selected color of the cell when selected
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.2696416974, green: 0.2744067311, blue: 0.27892676, alpha: 1)
            cell.selectedBackgroundView = backgroundView
            
        }else{
            cell.textLabel?.textColor = .black
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.selectedBackgroundView = backgroundView
        }
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        // The selected currency is the same as the one stored.
        print(currencies[indexPath.row].baseAbbriviation)
        print(asset?.currency)
        if currencies[indexPath.row].baseAbbriviation == asset?.currency {
            print("Samme velges")
            return
        }
        
        // toggle old one off and the new one on
        let newCell = tableView.cellForRow(at: indexPath)
        if newCell?.accessoryType == UITableViewCellAccessoryType.none {
            newCell?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        if let selPath = selectedIndexPath {
            let oldCell = tableView.cellForRow(at: selectedIndexPath!)
            if oldCell?.accessoryType == UITableViewCellAccessoryType.checkmark {
                oldCell?.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        
        selectedIndexPath = indexPath
        asset?.currency = currencies[indexPath.row].baseAbbriviation
        
        let appDelegate:AppDelegate
        let context:NSManagedObjectContext
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
//        var headerName = ""
//
//        if section == 0 {
//            headerName = "Cryptocurrencies"
//        }
//
//        return headerName
//    }
    
    @objc func doneButtonAction() {
        saveAsset()
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
    
    // Saves the current state of the asset
    func saveAsset(){
        let appDelegate:AppDelegate
        let context:NSManagedObjectContext
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        if let amountText = amountLabel.text{
            if amountText == ""{
                asset?.amount = 0.0
            }else{
                asset?.amount = amountText.toDoubleValue
            }
            
        }
        
        
        
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        portfolioEditViewController?.tableView.reloadData()
    }
}

// Put this piece of code anywhere you like
extension AddAsset {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddAsset.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        saveAsset()
        view.endEditing(true)
    }
}
