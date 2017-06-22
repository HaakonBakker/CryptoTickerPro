//
//  ViewController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 09/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import UIKit


class ViewController: UIViewController, ChartDelegate {
    
    @IBOutlet weak var chart: Chart!
    
    var pris:Cryptocurrency?
    
    // Labels in view
    @IBOutlet weak var priceButtonLeft: UITextField!
    @IBOutlet weak var priceButtonRight: UITextField!
    @IBOutlet weak var buyPriceLabel: UILabel!
    @IBOutlet weak var sellPriceLabel: UILabel!
    @IBOutlet weak var lastPriceLabel: UILabel!
    
    @IBOutlet weak var floatingPriceLabel: UILabel!
    
    // Buttons in view
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    var currentExchange:String = ""
    
    
    
    
    var tester:TesterFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tester = TesterFile()
        chart.delegate = self
        
        
        
        pris = Cryptocurrency()
        // Do any additional setup after loading the view, typically from a nib.
        test()
        
        tester.setDefaultExchange(exchange: "Coinbase")
        
        
        /* Need to complete this handler.*/
        /* The completion handler is not finished, because the while !ferdig loop. Have to fix this.*/
        if let thePris = pris {
            thePris.firstRefresh{
                print("this is cool")
                let enPris = thePris.getPrices();
                print(enPris)
                updateLabels(prices: enPris)
            }
        } else {
            //We don't have a price for that entry
        }
        
        //let chart = Chart()
        let series = ChartSeries([2324, 2344, 2560, 2450, 2388, 2399, 2395, 2340, 2504])
        series.color = ChartColors.whiteColor()
        chart.add(series)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func test() -> Void {
        
        if let thePris = pris {
            refreshTicker()
            //we got a valid price
        } else {
            //We don't have a price for that entry
            }
        
    }
    
    

    
    @IBAction func theRefreshButton(_ sender: Any) {
        refreshTicker()
    }
    
    func updateLabels(prices:[Double]) -> Void {
        
        //priceButtonLeft.text = prices[0].description + "$"// lastprice
        lastPriceLabel.text = prices[0].description + "$" // lastprice
        //buyPriceLabel.text = prices[1].description + "$" //buyprice
        //sellPriceLabel.text = prices[2].description + "$" //sellprice
    }
    
    func refreshTicker() -> Void {
        
        if let thePris = pris {
            
            let enPris = thePris.getPrices();
            updateLabels(prices: enPris)
            //we got a valid price
        } else {
            //We don't have a price for that entry
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
                    floatingPriceLabel.text = String(touchedValue)
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

