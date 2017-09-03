//
//  PortfolioViewController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 14/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PortfoliosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var allPortfolios:[Portfolio] = []
    var textCellIdentifier = "textCell"
    var portfolioController:PortfolioController!
    let defaults = UserDefaults.standard
    
    let formatter = NumberFormatter()
    
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var profitPercentLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    
    override func viewDidLoad() {
        // Set the formatter to decimal.
        formatter.numberStyle = NumberFormatter.Style.decimal
        initialLoadOfLabels()
        tableView.delegate = self
        tableView.dataSource = self
        print("Portfoliosview has been loaded")
        portfolioController = PortfolioController.shared()
        checkPortfolio()
        updateLabels()
        getPortfolioValues()
    }
    
    func initialLoadOfLabels() -> Void {
        var localCurrencySymbol = ""
        if let currencySymbol = self.defaults.object(forKey: "selectedCurrencySymbol") {
            localCurrencySymbol = currencySymbol as! String
        }else{
            print("No currency selected - something went wrong")
            localCurrencySymbol = "$"
        }
        
        var cost = "0"
        
        // Updating (cost, profit and profit%) if nothing happens
        self.costLabel.text = cost + localCurrencySymbol
        self.profitLabel.text = "0" + localCurrencySymbol
        self.profitPercentLabel.text = "0%"
    }
    
    func getPortfolioValues(){
        
        if portfolioController.ports.count == 0{
            initialLoadOfLabels()
            self.costLabel.text = "-"
            self.currentValueLabel.text = "-"
            return
        }
        
        var localCurrencySymbol = ""
        if let currencySymbol = self.defaults.object(forKey: "selectedCurrencySymbol") {
            localCurrencySymbol = currencySymbol as! String
        }else{
            print("No currency selected - something went wrong")
            localCurrencySymbol = "$"
        }
        
        // For each portfolio get current value
        let currentValueDouble = portfolioController.getPortfolioValue()
        
        var cost = "0"
        // For each portfolio get cost Value in local currency
        let costDouble = portfolioController.getPortfoliosCost(rate:{(success) -> Void in
            cost = String(format: "%.2f", success)
            
            DispatchQueue.main.async() {
                self.costLabel.text = self.getTwoDecimals(number: String(describing: cost)) + localCurrencySymbol
            }
            
            
            var profit = currentValueDouble - success
            
            // Calculate the percentage profit
            var percentProfit = (currentValueDouble - success)/currentValueDouble*100
            
            // Update the UI in the main queue
            DispatchQueue.main.async{
                // Need to fix the colors depending on profit or not
                
                // Set color based on positive or negative
                if (profit > 0){
                    // Positive change
                    self.profitLabel.textColor = UIColor(red: 0, green: 0.733, blue: 0.153, alpha: 1)
                    self.profitPercentLabel.textColor = UIColor(red: 0, green: 0.733, blue: 0.153, alpha: 1)
                    
                }else{
                    // Negative change
                    self.profitLabel.textColor = UIColor(red: 0.996, green: 0.125, blue: 0.125, alpha: 1)
                    self.profitPercentLabel.textColor = UIColor(red: 0.996, green: 0.125, blue: 0.125, alpha: 1)
                    
                }
                
                self.profitLabel.text = self.getTwoDecimals(number: String(describing: profit)) + localCurrencySymbol
                self.profitPercentLabel.text = self.getTwoDecimals(number: String(describing: percentProfit)) + "%"
            }
            
            
        })
        
        
        
        
        // Calculate profit and profit %
        
        // Convert Doubles to String
        let currentVal = self.getTwoDecimals(number: String(describing: currentValueDouble)) + localCurrencySymbol
        
        
        // Update labels
        currentValueLabel.text = currentVal
        
    }
    
    func updateLabels(){
        //print("Updating labels")
        // Update the cost of all Portfolios
        //costLabel.text = String(describing: portfolioController.getTotalPortfoliosCost())
        getPortfolioValues()
    }
    
    func checkPortfolio() -> Void {

        print("portfolioController")
        print(portfolioController)
        
    }
    
    @objc override func viewDidAppear(_ animated: Bool) {
        print("Portfolio View controller did appear again! Update the prices!")
        
        reloadData()
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        print("Portfolio View controller became active again! Update the prices!")
        reloadData()
    }
    
    func reloadData() -> Void {
        //allPortfolios = portfolioController.fetchPortfolios()
        portfolioController.updateStatus()
        updateLabels()
        self.tableView.reloadData()
        //self.currencyButton.setTitle(portfolio?.getCostCurrency() , for: .normal)
    }
    
    func loadPortfolios(){
        // Here we will load the portfolios saved in Core Data, as well as getting the elements for each portfolio
        
    }
    
    
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // Need to check if portfolio is initialized
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return cryptos.count
        var rowCount = 0
        
        rowCount = portfolioController.ports.count
        
        //rowCount = portfolioArr?.portArr?.count
        print("Row count: \(rowCount)")
        return rowCount
    }
    
    func getLocalCurrencySymbol() -> String {
        var localCurrencySymbol = ""
        if let currencySymbol = self.defaults.object(forKey: "selectedCurrencySymbol") {
            localCurrencySymbol = currencySymbol as! String
        }else{
            print("No currency selected - something went wrong")
            localCurrencySymbol = "$"
        }
        return localCurrencySymbol
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as UITableViewCell
        //print("UPDATING")
        cell.detailTextLabel?.textColor = UIColor.lightGray
        let section = indexPath.section
        let row = indexPath.row
        
        var portName:String!
        var cost:Double!
        
        // Getting stuff from the PortfolioController class to populate the TableView
        var port = portfolioController.ports[row]
        portName = portfolioController.ports[row].name
        cost = portfolioController.ports[row].cost
        
        cell.textLabel?.text = portName
        
        
        
        var portCalc = PortfolioCalculations(port: portfolioController.ports[row])
        var localCur = LocalCurrencies()
        if let costCur = port.costCurrency{
            cell.detailTextLabel?.text = self.getTwoDecimals(number: String(describing: portCalc.getCurrentValueWithTwoDecimal())) + getLocalCurrencySymbol()
        }else{
            // Have to default to USD
            cell.detailTextLabel?.text = self.getTwoDecimals(number: String(describing: portCalc.getCurrentValueWithTwoDecimal())) + "$"
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        let headerName = "Portfolios"
        return headerName
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        // No need to programatically create this function since it works through the Storyboard.
        
    }
    
    // MARK: Delete methods 
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            //let alertView = UIAlertController(title: "Delete Action", message: "", preferredStyle: UIAlertControllerStyle.alert)
            //alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            //UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
            
            
            
            
            // Verify with the user that he/she wants to delete
            // Create the alert controller
            let alertController = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete the portfolio?", preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NSLog("Delete")
                
                // Delete the Portfolio
                self.portfolioController.deletePortfolio(port: self.portfolioController.ports[indexPath.row])
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
            
            self.performSegue(withIdentifier: "editPortfolio", sender: indexPath)
            /*
            let alertView = UIAlertController(title: "Edit Action", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
             */
        })
        more.backgroundColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
        
        return [delete]
        // return [delete, more]
    }
    
    
    func getTwoDecimals(number:String) -> String {
        var intermediate = Double(number)
        var final = ""
        if let theIntermediate = intermediate {
            final = String(format: "%.2f", intermediate!)
        }
        
        if let myInteger = Double(final) {
            let myNumber = NSNumber(value:myInteger)
            var theFinal = formatter.string(from: myNumber)
            //print("RETURNERER DENNE : \(theFinal)")
            return theFinal!
        }
        return final as String
    }
    
    // MARK: Information Button
    
    @IBAction func infoButtonAction(_ sender: Any) {
        let alertController = UIAlertController(title: "How it works", message: "Add your portfolios to keep track of your holdings. Press Add to get started.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editPortfolio"{
            print("StemmertilEditPortfolio")
            let editViewController = (segue.destination as! PortfolioEditViewController)
            //editViewController.portfolio = portfolio
            //editViewController.portfolioViewController = self
            
        }
        
        if segue.identifier == "editPortfolioSegue"{
            print("Stemmer")
            let editViewController = (segue.destination as! PortfolioEditViewController)
            
            
            let appDelegate:AppDelegate
            let context:NSManagedObjectContext
            appDelegate = UIApplication.shared.delegate as! AppDelegate
            context = appDelegate.persistentContainer.viewContext
            
            let newPort = NSEntityDescription.insertNewObject(forEntityName: "Port", into: context) as! Port
            newPort.name = ""
            newPort.cost = 0
            newPort.costCurrency = "USD"
            
            
            //var newPort = Portfolio(theName:"My Portfolio")
            editViewController.portfolio = newPort
            
            //allPortfolios.append(newPort)

        }
        
        if segue.identifier == "portfolioViewIdentifier"{
            print("Stemmer")
            let portViewController = (segue.destination as! PortfolioViewController)
            let indexPath = tableView.indexPathForSelectedRow
            let port = portfolioController.ports[(indexPath?.row)!]
            portViewController.title = port.name
            portViewController.portfolio = port
        }
    }
}
