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
    
    
    var base:Double
    var target:Double
    var baseCurrency:String // Base currency (aka. 1 of this = x target currency)
    var baseAbbriviation:String
    var targetCurrency:String // Target currency
    var exchange:String // Exchange checked
    var changeLast24h:Double
    var volume:Double
    
    var prices:[String:Double]
    
    var blockchainURL: String
    
    init() {
        lastUpdated = NSDate.init()
        usdPrice = 0
        lastPrice = 0
        buyPrice = 0
        sellPrice = 0
        changeLast24h = 0
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
    
    
    func getTarget() -> Double {
        return target;
    }
    
    func getPrices() -> [Double] {
        let prices = [lastPrice, buyPrice, sellPrice]
        return prices
    }
    
    func getThePrice(currency:String) -> String {
        // Hent pris fra currency
        var pris = prices[currency]
        // Convert to String
        
        // Return
        guard let res = pris else {
            return "N/A"
        }
        let rundetPris = String(format: "%.2f", pris!)
        return rundetPris
    }
    
    
    /* This is the completion handler */
    /* The completion handler is not finished, because the while !ferdig loop. Have to fix this.*/
    
    func firstRefresh(finished: () -> Void) {
        updatePrice()
        let parser = Parser()
        var ferdig = false
        parser.networkRequest(APICall: blockchainURL, completion: { (success) -> Void in
            //print(success)
            // Get USD
            let price = success["USD"] as! Dictionary<String,Any>
            
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
            // Get USD
            let price = success["USD"] as! Dictionary<String,Any>
            
            self.lastPrice = price["last"]! as! Double
            self.buyPrice = price["buy"]! as! Double
            self.sellPrice = price["sell"]! as! Double
            
        })
        
    }
    
    
}
