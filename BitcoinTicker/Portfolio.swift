//
//  Portfolio.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 17/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation

class Portfolio {
    var cost:Double
    var costCurrency:String?
    var name:String
    var assets:[Element]
    
    let defaults = UserDefaults.standard
    
    init(theName:String){
        print("New Portfolio created")
        name = theName
        cost = 0.0
        assets = []
        costCurrency = self.setDefaultCostCurrency()
        
    }
    
    func getCostAsString() -> String{
        return String(describing: cost)
    }
    
    func getCostCurrency() -> String{
        return costCurrency!
    }
    
    func setDefaultCostCurrency() -> String {
        
        var selectedCurrency = ""
        // Default to USD
        if let currency = defaults.object(forKey: "selectedCurrency") {
            selectedCurrency = (currency as? String)!
        }else{
            print("No currency selected - something went wrong")
            // DEFAULT TO USD!
            selectedCurrency = "USD"
        }
            
        return selectedCurrency
    }
}

class Element {
    var currency:String
    var amount:Double
    
    init() {
        currency = ""
        amount = 0.0
    }
    
    func getName() -> String{
        return currency
    }
    func getAmount() -> Double {
        return amount
    }
}
