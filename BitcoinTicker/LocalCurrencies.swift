//
//  LocalCurrencies.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 17/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation

class LocalCurrencies{
    var fiats = ["USD", "NOK", "SEK", "EUR", "GBP", "CNY", "JPY"]
    var symbols:[String:String] = ["USD" : "$", "NOK" : "kr", "SEK" : "kr", "EUR" : "€", "GBP" : "£", "CNY" : "¥", "JPY" : "¥"]
    
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
}
