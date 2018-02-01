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
    var tableOfCryptocurrencies: TableOfCryptocurrencies?
    
    var devMode:Bool
    
    let appDelegate:AppDelegate
    let context:NSManagedObjectContext
    var currencies:[Cryptocurrency]
    var currencyList:[String:Cryptocurrency]
    let defaults = UserDefaults.standard
    
    static let sharedInstance = CryptoController()
    
    private init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        currencies = [Cryptocurrency]()
        currencyList = [:]
        devMode = true
        let needsDeletion = false
        let needsSaving = false
        let needsUpdating = true
        
        
        // Need a version check. If not 1.1 then delete all currencies and add the new ones.
        
//        if !defaults.bool(forKey: "hasBeenFixedSer1234" ){
//
//
//                self.deleteAllCurrencies()
//                print("ÆÆÆ Will delete")
//                self.checkVersionOfCurrencies()
//
//                defaults.set(true, forKey: "hasBeenFixedSer1234")
//
//
//        }else{
//            // Something weird happened.
//
//        }
        
        
        // We need to delete all currencies, then add the new ones.
        
        if !defaults.bool(forKey: "smallFix112"){
            self.deleteAllCurrencies()
            let mycryptoList:[String:AnyObject]
            if let path = Bundle.main.path(forResource: "CryptoPlist", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
                mycryptoList = dict
                //print(dict)
                // use swift dictionary as normal
                self.updateCurrencies(versionNumber: 40, dict: mycryptoList)
                defaults.set(true, forKey: "smallFix112")
            }
            defaults.set(true, forKey: "smallFix112")
        }
        
        
        
        
        
        
        
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
        
        
        /*
        // Redraw cells
        DispatchQueue.main.async{
            self.tableOfCryptocurrencies.tableView.reloadData()
        }
 */
        
    }
    
    func count() -> Int {
        return currencies.count
    }
    
    func getCurrencies() -> [Cryptocurrency] {
        currencies.sort { $0.mrkCap > $1.mrkCap }
        return currencies
    }
    
    func getCurrency(name:String) -> Cryptocurrency? {
        if let res = currencyList[name] {
            //print(res.getCurrencyInformation())
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
            var stringOfCurrencies = ""
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    let currency = Cryptocurrency()
//                    print(result.value(forKey: "mrkcap"))
                    var thename = " No name supplied"
                    if let name = result.value(forKey: "name") as? String {
                        //print(name)
                        currency.baseCurrency = name
                        
                    }
                    if let abbr = result.value(forKey: "abbreviation") as? String {
                        currency.baseAbbriviation = abbr
                        thename = abbr
                    }
                    if let price = result.value(forKey: "price") as? Double {
                        currency.target = price
                    }
                    
                    if let change24h = result.value(forKey: "change24h") as? Double {
                        currency.changeLast24h = change24h
                    }
                    
                    if let mrkcap = result.value(forKey: "mrkcap") as? Double {
                        currency.mrkCap = mrkcap
//                        print("*****" + thename + " -- " + String(mrkcap) )
                    }else{
                        currency.mrkCap = 0.0
                    }
                    
                    currencies.append(currency)
                    currencyList[currency.baseAbbriviation] = currency
                    stringOfCurrencies = stringOfCurrencies + "'" + currency.baseAbbriviation + "'" + ","
                    
                   
                }
//                print(stringOfCurrencies)
                
                currencies.sort { $0.mrkCap > $1.mrkCap }
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
            let currencyName = info["name"]
            //print(currencyName)
            //print("key is - \(key) and value is - \(value)")
            // Need to check if the currency excists, else add it.
            if let curr = getCurrency(name: abbreviation){
                // We'll do nothing, no need to update
            }else{
                saveCurrency(abbr: abbreviation, name: currencyName!)
            }
            
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
        let localCur = LocalCurrencies()
        let tsym = "tsyms=" + localCur.getAPIString()
        
        let APICall = header + fsym + "&" + tsym
//        print(APICall)
        return "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH&tsyms=USD"
//        return APICall
    }
    
    
    func createAPICallV2(dict:[String]) -> String {
        // Header aka. alt før det viktige
        let header = "https://min-api.cryptocompare.com/data/pricemulti?"
        
        // fsym -> Finne alle from symbols
        var fsym = "fsyms="
        
        for coin in dict {
            fsym = fsym.appending(coin)
            fsym = fsym.appending(",")
        }
        
        
        
        // tsym -> Add alle tosyms
        let localCur = LocalCurrencies()
        let tsym = "tsyms=" + localCur.getAPIString()
        
        let APICall = header + fsym + "&" + tsym
//        print(APICall)
        return APICall
        //        return APICall
    }
    
    func createChangeAPICall(dict:[String:Cryptocurrency], tsymCurrency:String) -> String {
        // Header aka. alt før det viktige
        let header = "https://min-api.cryptocompare.com/data/pricemultifull?"
        
        // fsym -> Finne alle from symbols
        var fsym = "fsyms="
        
        for (key, value) in dict {
            fsym = fsym.appending(key)
            fsym = fsym.appending(",")
        }
        
        
        
        
        
        
        let tsym = "tsyms=" + tsymCurrency
        
        let ts = "ts=1452680400"
        
        
        let APICall = header + fsym + "&" + tsym // + "&" + ts
//        print(APICall)
        return "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH&tsyms=USD"
//        return APICall
    }
    
    func createChangeAPICallV2(dict:[String], tsymCurrency:String) -> String {
        // Header aka. alt før det viktige
        let header = "https://min-api.cryptocompare.com/data/pricemultifull?"
        
        // fsym -> Finne alle from symbols
        var fsym = "fsyms="
        
        for coin in dict {
            fsym = fsym.appending(coin)
            fsym = fsym.appending(",")
        }
        
        
        
        
        
        
        let tsym = "tsyms=" + tsymCurrency
    
        
        
        let APICall = header + fsym + "&" + tsym // + "&" + ts
//        print(APICall)
        return APICall
        //        return APICall
    }
    
    func updatePrice() -> Void {
        
        var tsymCurrency = "USD"
        if let currency = self.defaults.object(forKey: "selectedCurrency") {
            // selectedCurrencySymbol
            tsymCurrency = (currency as? String)!
        }else{
//            print("No currency selected - something went wrong")
            // No default is set, we will continue with USD.
        }
        
        
        
        // Here comes the fun part!
        // We need to get the list of currencies to update, however, we want to update them 50 at a time.
        // The following is pseudocode for the update
        
        // Get the list of cryptos
        // For every 30 coins create an API Call String
            // Call the parser object with this string
            // Let it do its magic
        
        var counter = 0
        var coinStringList:[String] = []
        var APICallStringList:[String] = []
        var APIChangeCallStringList:[String] = []
        for coin in currencyList {
//            print(coin.key)
//            print(counter)
            counter = counter + 1
            
            coinStringList.append(coin.key)
            
            
            if counter == 25{
                // Here we will get the API call String and save that to the APICallStringList
                var apicall = createAPICallV2(dict: coinStringList)
                var apiChangeCall = createChangeAPICallV2(dict: coinStringList, tsymCurrency: tsymCurrency)
                
                APICallStringList.append(apicall)
                APIChangeCallStringList.append(apiChangeCall)
                coinStringList.removeAll()
                counter = 0
            }
        }
        
        // Need to check if the coinStringList is empty, if not then we need to update the rest
        if !coinStringList.isEmpty{
            var apicall = createAPICallV2(dict: coinStringList)
            var apiChangeCall = createChangeAPICallV2(dict: coinStringList, tsymCurrency: tsymCurrency)
            APICallStringList.append(apicall)
            APIChangeCallStringList.append(apiChangeCall)
            coinStringList.removeAll()
        }
        
//        print(APICallStringList)
        
        
        
        
        // For every API call we need to call the parser and call the updater
        for apiCall in APICallStringList {
        
            let parser = Parser()
            // Do any additional setup after loading the view, typically from a nib.
            
                parser.networkRequest(APICall: apiCall, completion: { (success) -> Void in
                    //print(success)
                    
                    print("START update pricing")
                    guard let tickerInfo:[String:Any] = success as? [String : Any] else{
                        
                        print("Something went wrong with the API call")
//                        print(apiCall)
//                        print(success["RAW"])
                        return
                    }
                
                    
                    for (key, value) in tickerInfo {
                        
//                        print(key)
                        let currency = key
                        
                        
                        let prices = value as! [String:Any]
                        //print("Currency: \(currency)")
                        //print("Prices: \(prices)")
                        
                        
                        // Update price on each crypto
                        self.updateCryptoPrice(currency: currency, prices: prices )
                        
                        // Redraw cells
                        DispatchQueue.main.async{
                            self.tableOfCryptocurrencies?.tableView.reloadData()
                        }
                    }
                    
                    print("SLUTT update pricing")
                })
        }
        
        
        
        let parser = Parser()
        let apiChange = createChangeAPICall(dict: currencyList, tsymCurrency: tsymCurrency)
        
        
        for apiCall in APIChangeCallStringList {
            parser.networkRequest(APICall: apiCall, completion: { (success) -> Void in
                //print(success)
                
                print("START change updating")
    //            print(success["RAW"] as! [String:Any?])
                let raw = success["RAW"] as! [String:Any?]
                //print(raw)
                for (key, value) in raw {
                    //let currency = key
                    let info = value as! [String:Any]
                    //print("Currency: \(currency)")
                    //print("Prices: \(prices)")
                    
                    //print(key)
                    //print(info[tsymCurrency])
                    
                    let data = info[tsymCurrency] as! [String:Any]
                    var change = 0.0
                    if let theChange = data["CHANGEPCT24HOUR"] as? Double{
                        change = theChange
                    }else{
                        change = 0.0
                    }
                    
                    // Will update the marketcap for the coin
                    if let mrkCap = data["MKTCAP"] as? Double{
                        if let price = data["PRICE"] as? Double{
                            self.updateCrypto(currency: key, mrkCap: mrkCap, price: price, change:change)
                        }
                        
                        
                        
                    }else{
                        change = 0.0
                    }
                    
                    
                    //Update change on each crypto
                    self.updateCryptoChange(currency: key, change: change)
                    //print("/////////")
                    // Redraw cells
                    DispatchQueue.main.async{
                        self.tableOfCryptocurrencies?.tableView.reloadData()
                    }
                }
                
                print("SLUTT change updating")
            })
            
        }
        
        
        
    }
    
    func updateCryptoPrice(currency:String, prices:[String:Any]) -> Void {
        // For the given currency, look up in a dict of currencies
        var elementToUpdate = getCurrency(name:currency)
        
        guard let res = elementToUpdate else {
            return
        }
        // Update all prices from prices dict.
        //print("Oppdatert!!!")
        print(prices)
        elementToUpdate!.prices = prices
        //print(elementToUpdate)
        //print(elementToUpdate?.prices)
        // Return
    }
    
    func updateCryptoChange(currency:String, change:Double) -> Void {
        // For the given currency, look up in a dict of currencies
        var elementToUpdate = getCurrency(name:currency)
        
        guard let res = elementToUpdate else {
            return
        }
        // Update all prices from prices dict.
        //print("Oppdatert!!!")
        elementToUpdate!.changeLast24h = change
        //print(elementToUpdate)
        //print(elementToUpdate?.prices)
        // Return
    }
    
    
    
    
    func updateCrypto(currency:String, mrkCap:Double, price:Double, change:Double) -> Void {
        // For the given currency, look up in a dict of currencies
        var elementToUpdate = getCurrency(name:currency)
        print("->" + currency + " -- " + String(describing: mrkCap))
        guard let res = elementToUpdate else {
            return
        }
        // Update all prices from prices dict.
        //print("Oppdatert!!!")
        res.mrkCap = mrkCap
        res.target = price
        res.changeLast24h = change
        
        // Update the mrkcap of the coin
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Crypto")
        
        let sortDescriptor = NSSortDescriptor(key: "abbreviation", ascending: true)
        
        let pred = NSPredicate(format:"abbreviation=%@", currency)
        
        request.predicate = pred
        
        request.sortDescriptors = [sortDescriptor]
        
        // Need to update on the main queue
        DispatchQueue.main.async(execute: {
            do{
                let results = try self.context.fetch(request)
                
                if results.count == 1 {
                    for result in results as! [NSManagedObject]{
                        result.setValue(mrkCap, forKey: "mrkcap")
                        result.setValue(price, forKey: "price")
                        result.setValue(change, forKey: "change24h")
                    }
                    
                    do{
                        try self.context.save()
                    }
                    catch
                    {
                        print(error)
                    }
                    
                    
                }
                
                    
                    
                
            }catch{
                // Do some error handling here.
                print("Something happened when fetching the request")
            }
        })
    }
    
    
    
    // MARK: - Accessors
    
    class func shared() -> CryptoController {
        return sharedInstance
    }
}
