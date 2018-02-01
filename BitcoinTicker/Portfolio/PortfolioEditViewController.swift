//
//  PortfolioEditViewController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 17/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class PortfolioEditViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let defaults = UserDefaults.standard
    
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var costCurrencyLabel: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameOfPortfolioLabel: UITextField!

    @IBOutlet var nameStaticLabel: UILabel!
    @IBOutlet var costStaticLabel: UILabel!
    @IBOutlet var costCurrencyStaticLabel: UILabel!
    
    
    var portfolio:Port!
    let formatter = NumberFormatter()
    var textCellIdentifier = "textCell"
    var portfolioViewController:PortfolioViewController!
    var arrayOfAssets:[El] = []
    var portfolioController = PortfolioController.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white;
       
        print(portfolio)
        self.hideKeyboardWhenTappedAround()
        
        
        self.nameOfPortfolioLabel.text = portfolio.name
        self.costCurrencyLabel.text = String(describing: portfolio.cost)
       
        self.nameOfPortfolioLabel.inputAccessoryView = addDoneButtonOverKeyboard()
        self.costCurrencyLabel.inputAccessoryView = addDoneButtonOverKeyboard()
        
        self.currencyButton.setAttributedTitle(getNSAttributedString(), for: .normal)
        //self.currencyButton.setTitle(portfolio?.getCostCurrency() , for: .normal)
        
        //self.currencyButton.setTitle("HELLO()" , for: .normal)
        //createTestElements()
        
        let elArr = portfolio?.elementRelationship
        arrayOfAssets = Array(elArr!) as! [El]
        
        tableView.delegate = self
        tableView.dataSource = self
        print("Portfolio Edit view has been loaded")
        
        // If no name has been set then show the keyboard right away
        if portfolio.name == ""{
            nameOfPortfolioLabel.becomeFirstResponder()
        }
        
        setTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        setTheme()
    }
    
    func setTheme(){
        if defaults.bool(forKey: "blackTheme" ){
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            //            self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            //            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.navigationController?.navigationBar.isTranslucent = false
            
            tableView.backgroundColor = .black
            self.tableView.separatorColor = #colorLiteral(red: 0.2510845065, green: 0.2560918033, blue: 0.2651863098, alpha: 1)
            view.backgroundColor = .black
            
            tableView.backgroundColor = .black
            
            costCurrencyLabel.textColor = .white
//            tableView.textColor = .white
            nameOfPortfolioLabel.textColor = .white
            
            nameStaticLabel.textColor = .white
            costStaticLabel.textColor = .white
            costCurrencyStaticLabel.textColor = .white
        }else{
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            
            tableView.backgroundColor = .white
            self.tableView.separatorColor = #colorLiteral(red: 0.8243665099, green: 0.8215891719, blue: 0.8374734521, alpha: 1)
            view.backgroundColor = #colorLiteral(red: 0.9593197703, green: 0.9626016021, blue: 0.9657023549, alpha: 1)
            
            currencyButton.titleLabel?.textColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            tableView.backgroundColor = .white
            costCurrencyLabel.textColor = .black
//            tableView.textColor = .black
            nameOfPortfolioLabel.textColor = .black
            
            nameStaticLabel.textColor = .black
            costStaticLabel.textColor = .black
            costCurrencyStaticLabel.textColor = .black
        }
    }
    
    func getNSAttributedString() -> NSAttributedString {
        var myString = portfolio?.costCurrency
        //let myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.blue ]
        let attrs = [NSForegroundColorAttributeName: UIColor.blue]
        let myAttrString = NSAttributedString(string: myString!, attributes: attrs)
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
        let elArr = portfolio?.elementRelationship
        arrayOfAssets = Array(elArr!) as! [El]
        print(portfolio)
        print(portfolio?.costCurrency)
        self.currencyButton.setAttributedTitle(getNSAttributedString(), for: .normal)
        tableView.reloadData()
        //self.currencyButton.setTitle(portfolio?.getCostCurrency() , for: .normal)
    }
    /*
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
    */
    func savePortfolio(){
        // Updating the previous view with the new information:
        //portfolioViewController.title = portfolio.name
        
        if let name = self.nameOfPortfolioLabel.text, let cost = self.costCurrencyLabel.text?.doubleValue {
            portfolio?.name = name
            portfolio?.cost = cost
            print("Saved the portfolio - name: \(String(describing: portfolio?.name)) -- cost: \(String(describing: portfolio?.cost))")
        }else{
            print("Cannot save, something is not correct.")
        }
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
            rowCount = (p.elementRelationship?.count)!
        }
        print("Row count: \(rowCount)")
        return rowCount
    }
    

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.font = UIFont(name: "Futura", size: 38)!
        
        if defaults.bool(forKey: "blackTheme" ){
            header.textLabel?.textColor = UIColor.white
            header.backgroundColor = .darkGray
        }else{
            header.textLabel?.textColor = UIColor.black
            header.backgroundColor = UIColor.white
        }
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        cell.detailTextLabel?.textColor = UIColor.lightGray
        let section = indexPath.section
        let row = indexPath.row
        
        let elArr = portfolio?.elementRelationship
        arrayOfAssets = Array(elArr!) as! [El]
        
        var cur = ""
        if let currency = arrayOfAssets[row].currency{
            cur = currency
        }
        var amount = arrayOfAssets[row].amount

        cell.detailTextLabel?.text = String(describing: amount)
        
        cell.textLabel?.text = cur
        
        
        
        // Add image
        if let image = UIImage(named: cur){
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        var headerName = ""

        if section == 0 {
            headerName = "Assets"
        }

        return headerName
    }
    
    // MARK: Delete methods
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            
            
            // Verify with the user that he/she wants to delete
            // Create the alert controller
            let alertController = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete the asset?", preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NSLog("Delete")
                
                // Delete the Portfolio
                self.portfolioController.deleteAsset(asset: self.arrayOfAssets[indexPath.row])
                // Save the Core Data context
                let appDelegate:AppDelegate
                let context:NSManagedObjectContext
                appDelegate = UIApplication.shared.delegate as! AppDelegate
                context = appDelegate.persistentContainer.viewContext
                do {
                    try context.save()
                    self.reloadData()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
                return
            }
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
            
        })
        delete.backgroundColor = UIColor.red
        
        
        let more = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            let alertView = UIAlertController(title: "Edit Action", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
            self.performSegue(withIdentifier: "editAsset", sender: indexPath)
        })
        more.backgroundColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
        
        //return [delete, more]
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editAsset", sender: indexPath)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCurrencyView"{
            print("Stemmer")
            let localCurrencyViewController = (segue.destination as! PortfolioLocalCurrencyViewController)
            //var newPort = Portfolio(theName:"My Portfolio")
            localCurrencyViewController.portfolio = portfolio

        }
        
        if segue.identifier == "editAsset"{
            print("Stemmer")
            let assetViewController = (segue.destination as! AddAsset)
            var indexPath = sender as! IndexPath
            assetViewController.asset = arrayOfAssets[indexPath.row]
            
            
            
            assetViewController.portfolioEditViewController = self
        }
        
        if segue.identifier == "addAssetSegue"{
            print("Adding a new asset")
            let assetViewController = (segue.destination as! AddAsset)
            
            let appDelegate:AppDelegate
            let context:NSManagedObjectContext
            appDelegate = UIApplication.shared.delegate as! AppDelegate
            context = appDelegate.persistentContainer.viewContext
            
            let newEl = NSEntityDescription.insertNewObject(forEntityName: "El", into: context) as! El
            //newEl.amount = 0
            newEl.relationship = portfolio
            
            assetViewController.asset = newEl
            assetViewController.portfolioEditViewController = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("The view is about to be dismissed")
        // Updating the previous view with the new information:
        //portfolioViewController.title = portfolio.name
        if let portVC = portfolioViewController{
            portVC.reloadData()
        }
        
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
