//
//  PortfolioCalculations.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 05/08/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation

class PortfolioCalculations{
    var portfolio:Port?
    
    var cryptoController:CryptoController?
    
    let defaults = UserDefaults.standard
    
    init(port:Port) {
        portfolio = port
        cryptoController = CryptoController.sharedInstance
    }
    
    func getCurrentValueWithTwoDecimal() -> String {
        
        var currentValue = calculateCurrentValue()
        
        let rundetPris = String(format: "%.2f", currentValue)
        return rundetPris
        
        return rundetPris
    }
    
    func getLocalCurrency() -> String {
        if let currency = self.defaults.object(forKey: "selectedCurrency") {
            return (currency as? String)!
        }else{
            print("No currency selected - something went wrong")
            // DEFAULT TO USD!
            return "USD"
        }
    }
    
    func calculateCost(rate: @escaping (Double) -> ()){
        var localCurrency = getLocalCurrency()
        var fiatCur = FiatCurrency.sharedInstance
        fiatCur.getConversionRate(fsym: portfolio!.costCurrency!, rate: { (success) -> Void in
            print(success)
            // We have the currency rate
            //var rate = success
            var rateDouble = Double(success)
            rate(success as! Double)
        })
        //return -2.0
    }
    
    func calculateCurrentValue() -> Double{
        // Need to get the local currency variable
        var localCurrency = getLocalCurrency()
        
        var totalValue = 0.0

        // Getting all the elements in the portfolio converting it to an array
        let elArr = portfolio?.elementRelationship
        let myArr = Array(elArr!)
        
        for asset in myArr as! [El]{
            guard let asCur = asset.currency else {
                continue
            }
            // For each asset get amount
            var amount = asset.amount
            
            // Need to check that the cryptocurrency actually exists, if not something is really wrong.
            guard var crypto = cryptoController?.getCurrency(name: asset.currency!) else {
                print("No currency connected to the asset, something went wrong.")
                continue
            }
            // For each asset get local currency value
            var cryptoPriceLocal = crypto.getDoublePrice(currency: localCurrency)
            
            // For each asset multiply assetAmount * localCurrencyValue
            var sumOfAsset = amount * cryptoPriceLocal
            
            totalValue = totalValue + sumOfAsset
            
            print("ASSET INFORMATION: Amount: \(amount) - sumOfAsset: \(sumOfAsset) - The asset currency \(asset.currency) - Asset price pr. 1: \(cryptoPriceLocal)")

        }
        print("TOTAL VALUE OF THIS PORTFOLIO: \(totalValue)")
        return totalValue
    }
    
  
}
