//
//  DetailCryptoViewController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 03/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class DetailCryptoViewController: UIViewController, ChartDelegate {
    let defaults = UserDefaults.standard
    
    var coin:String = ""
    var favoriteCurrency:String = ""
    
    var price:String = ""
    var localCurrencySymbol:String = ""
    
    // Labels and other things in view
    @IBOutlet weak var chart: Chart!
    //@IBOutlet weak var floatingPriceLabel: UILabel!
    @IBOutlet weak var conversionLabel: UILabel!
    @IBOutlet weak var changeLast24hLabel: UILabel!
    @IBOutlet weak var marketcapLabel: UILabel!
    @IBOutlet weak var numberOfCoinsLabel: UILabel!
    @IBOutlet weak var conversionPriceLabel: UILabel!
    @IBOutlet weak var changeLast24HourPercent: UILabel!
    
    var labels:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.navigationController?.navigationBar.backItem. = coin
        
        // Setting the back button on the controller object
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        print(coin)
        conversionLabel.text = coin + "/" + favoriteCurrency
        
        // Need to get the symbol for favorite coin
        
        if let currencySymbol = self.defaults.object(forKey: "selectedCurrencySymbol") {
            // selectedCurrencySymbol
            localCurrencySymbol = currencySymbol as! String
        }
        
        
        chart.delegate = self
        let series = ChartSeries([2324, 2344, 2560, 2450, 2388, 2399, 2395, 2340, 2504])
        series.color = ChartColors.blueColor()
        chart.add(series)
        
        // Need to get the updated prices
        getUpdatedPrices()
        // Need to update the labels.
        
    }
    
    func getUpdatedPrices() -> Void {
        // Need to get a json object
        let parser = Parser()
        let url = getRequestURL()
        parser.networkRequest(APICall: url, completion: { (success) -> Void in
            //print(success)
            
            
            /*
            print("START update pricing")
            for (key, value) in success {
                print(key)
                print(value)
            }
            print("SLUTT update pricing")
             */
            
            var raw = success["RAW"] as! [String:Any]
            var conversion = raw[self.coin] as! [String:Any]
            self.labels = conversion[self.favoriteCurrency] as! [String:Any]
            
            print(self.labels)
            
            
            self.updateLabels(labels: self.labels)
            
            
        })
        
    }
    
    func getRequestURL() -> String {
        print("https://min-api.cryptocompare.com/data/pricemultifull?fsyms=" + coin + "&tsyms=" + favoriteCurrency)
        return "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=" + coin + "&tsyms=" + favoriteCurrency
    }
    
    /*
     
     */
    func updateLabels(labels:[String:Any]) -> Void {
        // Update the labels based on the parameters
        print("I will update!")
        
        print("THIS")
        print(labels["PRICE"])
        print("THAT")
        
        if let b = labels["PRICE"]! as? String {
            print(b) // Was a string
        } else {
            print("Error") // Was not a string
            print(String(describing: labels["PRICE"]!))
            self.price = String(describing: labels["PRICE"]!)
        }
        
        
        /*
        conversionPriceLabel.text = labels["PRICE"] as! String
        changeLast24hLabel.text = labels["CHANGE24HOUR"] as! String
        setColorOn24hChange(change: labels["CHANGE24HOUR"]! as! String)
        marketcapLabel.text = labels["MKTCAP"] as! String
        numberOfCoinsLabel.text = labels["SUPPLY"] as! String
 */
        
        DispatchQueue.main.async() {
            self.conversionPriceLabel.text = self.getTwoDecimals(number: String(describing: labels["PRICE"]!)) + self.localCurrencySymbol
            
            print("CHANGE 24H: " + self.getTwoDecimals(number: String(describing: labels["CHANGE24HOUR"]!)) + self.localCurrencySymbol)
            self.changeLast24hLabel.text = self.getTwoDecimals(number: String(describing: labels["CHANGE24HOUR"]!)) + self.localCurrencySymbol
            self.changeLast24HourPercent.text = self.getTwoDecimals(number: String(describing: labels["CHANGEPCT24HOUR"]!)) + "%"
            self.setColorOn24hChange(change: String(describing: labels["CHANGE24HOUR"]!))
            self.marketcapLabel.text = self.getTwoDecimals(number: String(describing: labels["MKTCAP"]!)) + self.localCurrencySymbol
            self.numberOfCoinsLabel.text = self.getZeroDecimals(number: String(describing: labels["SUPPLY"]!))
            //print(self.price)
        }
    }
    
    func getTwoDecimals(number:String) -> String {
        var intermediate = Double(number)
        var final = String(format: "%.2f", intermediate!)
        return final as String
    }
    
    func getZeroDecimals(number:String) -> String {
        var intermediate = Double(number)
        var final = String(format: "%.0f", intermediate!)
        return final as String
    }
    
    func setColorOn24hChange(change:String) -> Void {
        var changeInt = Double(change)
        print(changeInt)
        // Set color based on positive or negative
        if (changeInt! > 0){
            // Positive change
            changeLast24hLabel.textColor = UIColor(red: 0, green: 0.733, blue: 0.153, alpha: 1)
            changeLast24HourPercent.textColor = UIColor(red: 0, green: 0.733, blue: 0.153, alpha: 1)
        }else{
            // Negative change
            changeLast24hLabel.textColor = UIColor(red: 0.996, green: 0.125, blue: 0.125, alpha: 1)
            changeLast24HourPercent.textColor = UIColor(red: 0.996, green: 0.125, blue: 0.125, alpha: 1)
        }
    }
    
    // Chart delegate
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        // Do something on touch
        for (serieIndex, dataIndex) in indexes.enumerated() {
            if dataIndex != nil {
                // The series at serieIndex has been touched
                let value = chart.valueForSeries(serieIndex, atIndex: dataIndex)
                //print(chart.valueForSeries(Int(x), atIndex: dataIndex))
                print(value)
                if let touchedValue = value {
                    //floatingPriceLabel.text = String(touchedValue)
                }else{
                    print("Something went wrong")
                }
                
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        // Do something when finished
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        // Do something when ending touching chart
    }
}

