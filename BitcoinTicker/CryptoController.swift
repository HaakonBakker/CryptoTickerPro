//
//  CryptoController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 20/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CryptoController {
    
    // Trenger denne for å snakke med tableview
    let tableOfCryptocurrencies: TableOfCryptocurrencies
    
    var devMode:Bool
    
    let appDelegate:AppDelegate
    let context:NSManagedObjectContext
    var currencies:[Cryptocurrency]
    var currencyList:[String:Cryptocurrency]
    
    
    init(tableController: TableOfCryptocurrencies) {
        
        devMode = true
        let needsDeletion = true
        let needsSaving = false
        let needsUpdating = true
        
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        currencies = [Cryptocurrency]()
        currencyList = [:]
        tableOfCryptocurrencies = tableController
        
        
        
        let start = NSDate(); // <<<<<<<<<< Start time
        
        if devMode {
            if needsDeletion{
                self.deleteAllCurrencies()
                let defaults = UserDefaults.standard
                defaults.set(0, forKey: "currentVersionNumber")
            }
            if needsSaving{
                self.saveCurrencies()
            }
            
            if needsUpdating{
                self.checkVersionOfCurrencies()
            }
        }
        
        
        let end = NSDate();   // <<<<<<<<<<   end time
        
        let timeInterval: Double = end.timeIntervalSince(start as Date); // <<<<< Difference in seconds (double)
        
        print("Time to update the currencylist: \(timeInterval) seconds")
        
        
        // Load all currencies into memory
        loadCurrencies()
        
        // Update the price
        updatePrice()
        
        
        // Redraw cells
        DispatchQueue.main.async{
            self.tableOfCryptocurrencies.tableView.reloadData()
        }
    }
    
    func count() -> Int {
        return currencies.count
    }
    
    func getCurrencies() -> [Cryptocurrency] {
        return currencies
    }
    
    func getCurrency(name:String) -> Cryptocurrency? {
        if let res = currencyList[name] {
            return res
        }else{
            print("Couldn't find the currency: \(name)")
        }
        return nil
    }
    
    
    func loadCurrencies() -> Void{
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Crypto")
        
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    let currency = Cryptocurrency()
                    if let name = result.value(forKey: "name") as? String {
                        //print(name)
                        currency.baseCurrency = name
                    }
                    if let abbr = result.value(forKey: "abbreviation") as? String {
                        currency.baseAbbriviation = abbr
                    }
                    if let price = result.value(forKey: "price") as? Double {
                        currency.target = price
                    }
                    currencies.append(currency)
                    currencyList[currency.baseAbbriviation] = currency
                }
            }
        }catch{
            // Do some error handling here.
        }
    }
    
    func saveCurrencies(){
        let newCurrency = NSEntityDescription.insertNewObject(forEntityName: "Crypto", into: context)
        
        newCurrency.setValue("Bitcoin", forKey: "name")
        newCurrency.setValue("BTC", forKey: "abbreviation")
        newCurrency.setValue(2606.51, forKey: "price")
        
        do{
            try context.save()
        }
        catch{
            // PROCESS ERROR HERE
        }
        
        let anotherCurrency = NSEntityDescription.insertNewObject(forEntityName: "Crypto", into: context)
        anotherCurrency.setValue("Ethereum", forKey: "name")
        anotherCurrency.setValue("ETH", forKey: "abbreviation")
        anotherCurrency.setValue(359.66, forKey: "price")
        
        do{
            try context.save()
        }
        catch{
            // PROCESS ERROR HERE
        }
    }
    
    func deleteAllCurrencies() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Crypto")
        
        if let result = try? context.fetch(request)  {
            for object in result as! [NSManagedObject] {
                context.delete(object)
            }
        }
    }
    
    
    func checkVersionOfCurrencies(){
        print("I'm updating currencies")
        
        // Check that the CryptPlist is present - if not, return!! (Something is wrong)
        let cryptoList:[String:AnyObject]
        if let path = Bundle.main.path(forResource: "CryptoPlist", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            cryptoList = dict
            //print(dict)
            // use swift dictionary as normal
        }else{
            return
        }
        
        // Get Plist version
        var plistVersion = -1
        if let path = Bundle.main.path(forResource: "VersionPlist", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            plistVersion = dict["VersionNumber"] as! Int
            //print(dict)
            // use swift dictionary as normal
        }
        
        // Get current version for currencies
        let defaults = UserDefaults.standard
        var userVersion:Int!
        if let currentVersion = defaults.object(forKey: "currentVersionNumber") {
            print("Current Version: ", currentVersion as! Int)
            userVersion = currentVersion as! Int
        }else{
            print("Something went wrong, no local version for the app is present. Should update the currencylist.")
            userVersion = -1
        }
        
        if plistVersion > userVersion {
            print("Plist is larger than user, should update the currencylist of the application.")
            print("Update needed")
            updateCurrencies(versionNumber: plistVersion, dict: cryptoList)
        }else{
            print("The user has the same version number (or larger?!?!). LocalUser: \(userVersion), plistVersion: \(plistVersion)")
            print("No need to update")
        }
        
        
    }
    
    
    func updateCurrencies(versionNumber:Int, dict:[String:AnyObject]) -> Void {
        // Need to update the currencylist in that sits in Core Data
        for (key, value) in dict {
            let abbreviation = key
            let info = value as! [String:String]
            let currencyName = info["name"] as! String
            //print(currencyName)
            //print("key is - \(key) and value is - \(value)")
            saveCurrency(abbr: abbreviation, name: currencyName)
        }
        // Need to update the userDefault that is the local version number.
        let defaults = UserDefaults.standard
        defaults.set(versionNumber, forKey: "currentVersionNumber")
        print("New local version number set. Current local version number: \(versionNumber)")
        //self.loadCurrencies()
        
    }
    
    func saveCurrency(abbr:String, name:String){
        let newCurrency = NSEntityDescription.insertNewObject(forEntityName: "Crypto", into: context)
        
        newCurrency.setValue(name, forKey: "name")
        newCurrency.setValue(abbr, forKey: "abbreviation")
        //newCurrency.setValue(2606.51, forKey: "price")
        
        do{
            try context.save()
        }
        catch{
            // PROCESS ERROR HERE
        }
    }
    
    func createAPICall(dict:[String:Cryptocurrency]) -> String {
        // Header aka. alt før det viktige
        let header = "https://min-api.cryptocompare.com/data/pricemulti?"
        
        // fsym -> Finne alle from symbols
        var fsym = "fsyms="
        
        for (key, value) in dict {
            fsym = fsym.appending(key)
            fsym = fsym.appending(",")
        }
        
        
        
        // tsym -> Add alle tosyms
        
        let tsym = "tsyms=USD,EUR,NOK,SEK,GBP,CNY,JPY"
        
        let APICall = header + fsym + "&" + tsym
        print(APICall)
        return APICall
    }
    
    func updatePrice() -> Void {
        
        
        let apiCall = createAPICall(dict: currencyList)
        // return Price data
        let parser = Parser()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        parser.networkRequest(APICall: apiCall, completion: { (success) -> Void in
            //print(success)
            
            print("START update pricing")
            for (key, value) in success {
                let currency = key
                let prices = value as! [String:Double]
                //print("Currency: \(currency)")
                //print("Prices: \(prices)")
                
                
                // Update price on each crypto
                self.updateCryptoPrice(currency: currency, prices: prices)
                
                // Redraw cells
                DispatchQueue.main.async{
                    self.tableOfCryptocurrencies.tableView.reloadData()
                }
            }
            
            print("SLUTT update pricing")
        })
        
        
        
    }
    
    func updateCryptoPrice(currency:String, prices:[String:Double]) -> Void {
        // For the given currency, look up in a dict of currencies
        var elementToUpdate = getCurrency(name:currency)
        
        guard let res = elementToUpdate else {
            return
        }
        // Update all prices from prices dict.
        //print("Oppdatert!!!")
        elementToUpdate!.prices = prices
        //print(elementToUpdate)
        //print(elementToUpdate?.prices)
        // Return
    }
    
    
}
