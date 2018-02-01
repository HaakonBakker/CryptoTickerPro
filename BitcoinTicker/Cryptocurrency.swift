//
//  Price.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 09/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation

class Cryptocurrency{
    var usdPrice: Double
    
    
    // General price variables
    var lastPrice:Double
    var buyPrice:Double
    var sellPrice:Double
    var lastUpdated:NSDate
    
    let defaults = UserDefaults.standard
    
    
    var base:Double
    var target:Double
    var baseCurrency:String // Base currency (aka. 1 of this = x target currency)
    var baseAbbriviation:String
    var targetCurrency:String // Target currency
    var exchange:String // Exchange checked
    var changeLast24h:Double
    var mrkCap:Double
    var volume:Double
    
    
    
    var prices:[String:Any]
    
    var blockchainURL: String
    
    init() {
        lastUpdated = NSDate.init()
        usdPrice = 0
        lastPrice = 0
        buyPrice = 0
        sellPrice = 0
        changeLast24h = 0
        mrkCap = 0
        base = 0
        target = 0
        volume = 0
        prices = [:]
        baseCurrency = ""
        baseAbbriviation = ""
        targetCurrency = ""
        exchange = "Blockchain"
        
        blockchainURL = "https://blockchain.info/ticker"
        updatePrice()
    }
    
    func getCurrencyInformation(){
        print(baseCurrency)
        print(baseAbbriviation)
        print(changeLast24h)
        print(prices)
        print(target)
        print(lastPrice)
    }
    
    func getTarget() -> Double {
        return target;
    }
    
    func getPrices() -> [Double] {
        let prices = [lastPrice, buyPrice, sellPrice]
        return prices
    }
    
    func getmrkcap() -> Double{
        return mrkCap
    }
    
    func getThePrice(currency:String) -> String {
        // Hent pris fra currency
        var pris = prices[currency]
        // Convert to String
        
  
        // Return
        guard let res = pris else {
            // No current price info (get previous)
            var pris = target
            var rundetPris = String(format: "%.2f", pris)
            return rundetPris
            
            // Will not be called, we're now using the last gotten price info value.
            return "Updating..."
        }
        
//        print("->" + currency)
//        print(res["PRICE"])
//        testingPriceJSON(currency: currency)
        
        
        
        
        let rundetPris = String(format: "%.2f", res as! Double)
        return rundetPris
    }
    
    func getTheDoublePrice(currency:String) -> Double{
        var pris = prices[currency]
        // Convert to String
        
        
        // Return
        guard let res = pris else {
            return 0
        }
        
        if let res:Double = pris as! Double{
            return res
        }
        
        return 0
        
    }
    
    func testingPriceJSON(currency:String){
        // Print the price
//        print("***********")
//        print(prices)
//        print("***********END")
    }
    
    func getDoublePrice(currency:String) -> Double {
        // Hent pris fra currency
        if let pris = prices[currency]{
            return pris as! Double
        }else{
            return 0.0
        }
    }
    
    
    /* This is the completion handler */
    /* The completion handler is not finished, because the while !ferdig loop. Have to fix this.*/
    
    func firstRefresh(finished: () -> Void) {
        updatePrice()
        let parser = Parser()
        var ferdig = false
        parser.networkRequest(APICall: blockchainURL, completion: { (success) -> Void in
            //print(success)
            // Get local Currency
            var localCurrency = ""
            if let currency = self.defaults.object(forKey: "selectedCurrency") {
                localCurrency = (currency as? String)!
            }else{
                print("No currency selected - something went wrong")
                // DEFAULT TO USD!
                localCurrency = "USD"
            }
            
            let price = success[localCurrency] as! Dictionary<String,Any>
            
            self.lastPrice = price["last"]! as! Double
            self.buyPrice = price["buy"]! as! Double
            self.sellPrice = price["sell"]! as! Double
            ferdig = true
        })
        while !ferdig {
            
        }
        finished()
        
    }
    
    func updatePrice() -> Void {
        
        let parser = Parser()
        
        parser.networkRequest(APICall: blockchainURL, completion: { (success) -> Void in
            //print(success)
            // Get local currency
            var localCurrency = ""
            if let currency = self.defaults.object(forKey: "selectedCurrency") {
                localCurrency = (currency as? String)!
            }else{
                print("No currency selected - something went wrong")
                // DEFAULT TO USD!
                localCurrency = "USD"
            }
            
            let price = success["EUR"] as! Dictionary<String,Any>
            
            self.lastPrice = price["last"]! as! Double
            self.buyPrice = price["buy"]! as! Double
            self.sellPrice = price["sell"]! as! Double
            
        })
        
    }
    
    
}
