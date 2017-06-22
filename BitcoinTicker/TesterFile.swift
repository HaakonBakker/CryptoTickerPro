//
//  TesterFile.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 14/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation

class TesterFile {
    init() {
        
    }
    
    func setDefaultExchange(exchange:String) -> Void {
        
        let defaults = UserDefaults.standard
        
        
        print("Old Exchange", defaults.string(forKey: "Exchange"))
        
        
        
        defaults.set(exchange, forKey: "Exchange")
        print("Current Exchange", defaults.string(forKey: "Exchange"))
    }
}
