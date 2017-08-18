//
//  FiatCurrency.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 06/08/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FiatCurrency{
    static let sharedInstance = FiatCurrency()
    let appDelegate:AppDelegate
    let context:NSManagedObjectContext
    var priceMatrix:[String:Any]
    let defaults = UserDefaults.standard
    
    private init() {
        priceMatrix = [:]
        // Set up core data
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        getMatrix()
    }
    
    func getConversionRate(fsym: String, rate: @escaping (Double) -> ()){
        let parser = Parser()
        
        // Find the toSym (local currency)
        var localCurrency = ""
        if let currency = self.defaults.object(forKey: "selectedCurrency") {
                // selectedCurrencySymbol
                localCurrency = (currency as? String)!
        }else{
            print("No currency selected - something went wrong")
            // DEFAULT TO USD!
            localCurrency = "USD"
        }
        
        var apiCall = createAPICall(fsym: fsym, tsym: localCurrency)
        parser.networkRequest(APICall: apiCall, completion: {success in
            print(success)
            rate(success[localCurrency] as! Double)
        })
    }
    
    func getConversionRateDoubleReturn(fsym: String, rate: @escaping (Double) -> (Double)){
        let parser = Parser()
        
        // Find the toSym (local currency)
        var localCurrency = ""
        if let currency = self.defaults.object(forKey: "selectedCurrency") {
            // selectedCurrencySymbol
            localCurrency = (currency as? String)!
        }else{
            print("No currency selected - something went wrong")
            // DEFAULT TO USD!
            localCurrency = "USD"
        }
        
        var apiCall = createAPICall(fsym: fsym, tsym: localCurrency)
        parser.networkRequest(APICall: apiCall, completion: {success in
            print(success)
            rate(success[localCurrency] as! Double)
        })
    }
    
    func getMatrix(){
        let parser = Parser()
        
        //parser.networkRequest(APICall: self.createAPICall(), completion: {success in print(success)})
        
    }
    
    func createAPICall(fsym:String, tsym:String) -> String{
        return "https://min-api.cryptocompare.com/data/price?fsym=\(fsym)&tsyms=\(tsym)"
    }
}
