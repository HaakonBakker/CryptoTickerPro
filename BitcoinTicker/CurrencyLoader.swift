//
//  CurrencyLoader.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 23/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CurrencyLoader {
    

    
    let appDelegate:AppDelegate
    let context:NSManagedObjectContext
    var currencies:[Cryptocurrency]
    var currencyList:[String:Cryptocurrency]
    
    
    init() {
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        currencies = [Cryptocurrency]()
        currencyList = [:]
        
        self.loadCurrencies()
    }
    
    
    func getCurrencies() -> [Cryptocurrency] {
        return currencies
    }
    
    func getCurrencyList() -> [String:Cryptocurrency] {
        return currencyList
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
                        print(name)
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
}
