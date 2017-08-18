//
//  LocalCurrencies.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 17/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation

class LocalCurrencies{
    var fiats = ["USD", "NOK", "SEK", "EUR", "GBP", "CNY", "JPY", "AUD", "BRL", "CAD", "HRK", "DKK", "HKD", "INR", "ISK", "PKR", "SGD", "CHF"]
    var symbols:[String:String] = ["USD" : "$", "NOK" : "kr", "SEK" : "kr", "EUR" : "€", "GBP" : "£", "CNY" : "¥", "JPY" : "¥", "AUD": "$", "BRL": "R$", "CAD": "$", "HRK" : "kn", "DKK" : "kr", "HKD" : "$", "INR" : "₹", "ISK" : "kr", "PKR" : "₨", "SGD" : "$", "CHF" : "CHF"]
    init() {
        
    }
    
    func getFiats() -> [String]{
        return fiats
    }
    func getFiat(number:Int) -> String{
        return fiats[number]
    }
    
    func getSymbols() -> [String:String]{
        return symbols
    }
    func getSymbol(currency:String) -> String {
        return symbols[currency]!
    }
    
    func getAPIString() -> String{
        var currencyStringWithDelimiter = ""
        
        var counter = 0
        
        for fiat in fiats {
            if counter == fiats.count{
                currencyStringWithDelimiter = currencyStringWithDelimiter + fiat
            }
            currencyStringWithDelimiter = currencyStringWithDelimiter + fiat + ","
            counter = counter + 1
        }
        return currencyStringWithDelimiter
    }
    
}
