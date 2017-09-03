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
    var usdPrice:Double = 0.0
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
    @IBOutlet weak var cryptoLogoImageView: UIImageView!
    @IBOutlet weak var graphLabel: UILabel!
    @IBOutlet weak var graphChangePercent: UILabel!
    @IBOutlet weak var volume24HCoinLabel: UILabel!
    @IBOutlet weak var volume24HLocalLabel: UILabel!
    @IBOutlet weak var high24HLabel: UILabel!
    @IBOutlet weak var low24HLabel: UILabel!
    @IBOutlet weak var volume24HCoin: UILabel!
    @IBOutlet weak var volume24HLocal: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var chartConversionLabel: UILabel!
    @IBOutlet weak var chartConversionPriceLabel: UILabel!
    
    // Graph change labels
    
    @IBOutlet weak var graphChangeLabel: UILabel!
    @IBOutlet weak var graphChangePCTLabel: UILabel!
    @IBOutlet weak var graphTopLabel: UILabel!
    @IBOutlet weak var graphBottomLabel: UILabel!
    
    let formatter = NumberFormatter()
    
    var labels:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the formatter to decimal.
        formatter.numberStyle = NumberFormatter.Style.decimal
        
        // Do any additional setup after loading the view.
        //self.navigationController?.navigationBar.backItem. = coin
        
        // Setting the back button on the controller object
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        print(coin)
        conversionLabel.text = coin + "/" + favoriteCurrency
        chartConversionLabel.text = coin + "/" + "USD"
        
        // Setting Volume labels
        volume24HCoinLabel.text = "Volume 24H - " + coin
        volume24HLocalLabel.text = "Volume 24H - " + favoriteCurrency
        
        
        
        // Add image to Crypto Logo
        cryptoLogoImageView?.image = UIImage(named: coin)
        
        
        // Need to get the symbol for favorite coin
        
        if let currencySymbol = self.defaults.object(forKey: "selectedCurrencySymbol") {
            // selectedCurrencySymbol
            localCurrencySymbol = currencySymbol as! String
        }
        
        
        
        chart.delegate = self
        
        updateChart1Week()
        // Need to get the updated prices
        getUpdatedPrices()
        // Need to update the labels.
        
        // GET USD Price changes
        updateUSDPriceLabels()
        
    }
    
    
    func updateChart1Hour() -> Void {
        // Remove everything at first.
        
        
        
        
        //let data = [(x: Float(0), y: Float(0)), (x: Float(0.5), y: Float(3.1))]
        //let data: Array<Float> = [0.0,  -2.70548,  -2.63699,  3.09075,  -3.05268, 0.0, 4.44349, 1.0, 0.0, -1.30397, 0.0, 0.0, 1.64384, -3.17637, 4.92295, -1.89212, -3.44178, -4.09326, 0.0, 2.06336, -2.5, 2.74829, -4.8532, 1.4726, -2.32021, 0.0, 0.0, -4.375, 4.10663, -0.821326, -1.77233, 1.73801]
        //let series = ChartSeries(data)
        // Create a new series specifying x and y values
        
        
        
        // Need to get a json object
        let parser = Parser()
        let url = getChartRequestURL(typeOfRequest:"minute", aggregate:1, limit:60)
        parser.networkRequest(APICall: url, completion: { (success) -> Void in
            self.chart.removeAllSeries()
            var raw = success["Data"]
            //var conversion = raw[self.coin] as! [String:Any]
            //self.labels = conversion[self.favoriteCurrency] as! [String:Any]
            //var raw = success["Data"] as! [String:Any]
            //print(success)
            //print(raw)
            var first = 0.0
            var last = 0.0
            var top = 0.0
            var bottom = 0.0
            var pointCounter = 0
            
            var test = raw as! NSArray
            
            //self.updateLabels(labels: self.labels)
            
            var dates:[Date] = []
            var datesAsString:[String] = []
            var dataPoints:[(x:(Float), y:(Float))] = []
            print(type(of: test[1]))
            var counter:Float = 0
            
            // lastDateString
            var lastDateString:String = ""
            
            var labelCounter:Int = 0
            
            for point in test{
                //print(type(of: point))
                var dataPoint = point as! Dictionary<String, Any>
                //print(dataPoint["time"])
                
                //let date = Date(timeIntervalSince1970: timeStamp)
                //print(date)
                //dates.append(date)
                
                if let t = dataPoint["time"] {
                    let timeStamp = dataPoint["time"] as! Double
                    let date = Date(timeIntervalSince1970: timeStamp)
                    //print(date)
                    dates.append(date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-hh:mma"
                    let dateString = dateFormatter.string(from: date)
                    
                    
                    
                    if let date = dateFormatter.date(from: dateString) {
                        
                        dateFormatter.dateFormat = "hh:mma"
                        print("Time is \(dateFormatter.string(from: date))")
                        let m = dateFormatter.string(from: date)
                        //dateFormatter.dateFormat = "dd"
                        //print("date is \(dateFormatter.string(from: date))")
                        //let d = dateFormatter.string(from: date)
                        
                        let newDate = m
                        
                        if (labelCounter == 15){
                            //labels.append(Float(i))
                            datesAsString.append(newDate)
                            lastDateString = newDate
                            labelCounter = 0
                        }else{
                            labelCounter = labelCounter + 1
                            if (datesAsString.count == 0){
                                datesAsString.append(newDate)
                                //lastDateString = newDate
                            }
                        }
                        
                    }
                }else{
                    print("Something is not right.")
                }
                if let t = dataPoint["close"]{
                    let k = t as! Double
                    
                    dataPoints.append(((x:Float(counter), y: Float(k))))
                    
                    // Get the other datapoints
                    if pointCounter == 0{
                        first = k
                        top = k
                        bottom = k
                    }
                    last = k
                    
                    // Top
                    if k > top {
                        top = k
                    }
                    
                    // Bottom
                    if k < bottom {
                        bottom = k
                    }
                    pointCounter = pointCounter + 1
                }else{
                    print("Something is not right1.")
                }
                
                counter = counter + 0.066666666
                print("Counter: " + String(describing: counter))
                print("Count of datesAsString: " + String(describing: datesAsString.count))
            }
            
            DispatchQueue.main.async() {
                
                let series = ChartSeries([Float(0)])
                //series.data = []
                series.data = dataPoints
                
                print(dataPoints.count)
                self.chart.xLabels = [0,1,2,3]
                self.chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
                    print(labelIndex)
                    return datesAsString[labelIndex]
                }
                
                self.chart.add(series)
                
                
                // Update the change labels
                
                self.graphChangeLabel.text = self.getTwoDecimals(number: String(describing: (last-first))) + "$"
                let percentChange = (last - first)/first*100
                self.graphChangePCTLabel.text = self.getTwoDecimals(number: String(describing: percentChange)) + "%"
                self.graphTopLabel.text = self.getTwoDecimals(number: String(describing: top)) + "$"
                self.graphBottomLabel.text = self.getTwoDecimals(number: String(describing: bottom)) + "$"
            }
            
        })
        
        
    }
    
    func updateChart1Day() -> Void {
        // Remove everything at first.
        
        
        
        
        //let data = [(x: Float(0), y: Float(0)), (x: Float(0.5), y: Float(3.1))]
        //let data: Array<Float> = [0.0,  -2.70548,  -2.63699,  3.09075,  -3.05268, 0.0, 4.44349, 1.0, 0.0, -1.30397, 0.0, 0.0, 1.64384, -3.17637, 4.92295, -1.89212, -3.44178, -4.09326, 0.0, 2.06336, -2.5, 2.74829, -4.8532, 1.4726, -2.32021, 0.0, 0.0, -4.375, 4.10663, -0.821326, -1.77233, 1.73801]
        //let series = ChartSeries(data)
        // Create a new series specifying x and y values
        
        
        
        // Need to get a json object
        let parser = Parser()
        let url = getChartRequestURL(typeOfRequest:"minute", aggregate:15, limit:96)
        parser.networkRequest(APICall: url, completion: { (success) -> Void in
            self.chart.removeAllSeries()
            var raw = success["Data"]
            
            var first = 0.0
            var last = 0.0
            var top = 0.0
            var bottom = 0.0
            var pointCounter = 0
            
            print(type(of: success["Data"]))
            
            var test = raw as! NSArray
            print(test[1])
            //self.updateLabels(labels: self.labels)
            
            var dates:[Date] = []
            var datesAsString:[String] = []
            var dataPoints:[(x:(Float), y:(Float))] = []
            print(type(of: test[1]))
            var counter:Float = 0
            
            // lastDateString
            var lastDateString:String = ""
            
            var labelCounter:Int = 0
            
            for point in test{
                //print(type(of: point))
                var dataPoint = point as! Dictionary<String, Any>
                //print(dataPoint["time"])
                
                //let date = Date(timeIntervalSince1970: timeStamp)
                //print(date)
                //dates.append(date)
                
                if let t = dataPoint["time"] {
                    let timeStamp = dataPoint["time"] as! Double
                    let date = Date(timeIntervalSince1970: timeStamp)
                    //print(date)
                    dates.append(date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-hh:mma"
                    let dateString = dateFormatter.string(from: date)
                    
                    
                    
                    if let date = dateFormatter.date(from: dateString) {
                        
                        dateFormatter.dateFormat = "hha"
                        print("Hour is \(dateFormatter.string(from: date))")
                        let m = dateFormatter.string(from: date)
                        //dateFormatter.dateFormat = "dd"
                        //print("date is \(dateFormatter.string(from: date))")
                        //let d = dateFormatter.string(from: date)
                        
                        let newDate = m
                        
                        if (labelCounter == 24){
                            //labels.append(Float(i))
                            datesAsString.append(newDate)
                            lastDateString = newDate
                            labelCounter = 0
                        }else{
                            labelCounter = labelCounter + 1
                            if (datesAsString.count == 0){
                                datesAsString.append(newDate)
                                //lastDateString = newDate
                            }
                        }
                        
                    }
                }else{
                    print("Something is not right.")
                }
                if let t = dataPoint["close"]{
                    let k = t as! Double
                    
                    dataPoints.append(((x:Float(counter), y: Float(k))))
                    
                    // Get the other datapoints
                    if pointCounter == 0{
                        first = k
                        top = k
                        bottom = k
                    }
                    last = k
                    
                    // Top
                    if k > top {
                        top = k
                    }
                    
                    // Bottom
                    if k < bottom {
                        bottom = k
                    }
                    pointCounter = pointCounter + 1
                    
                }else{
                    print("Something is not right1.")
                }
                
                counter = counter + 0.04210
                print("Counter: " + String(describing: counter))
                print("Count of datesAsString: " + String(describing: datesAsString.count))
            }
            
            DispatchQueue.main.async() {
                
                let series = ChartSeries([Float(0)])
                //series.data = []
                series.data = dataPoints
                
                print(dataPoints.count)
                self.chart.xLabels = [0,1,2,3]
                self.chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
                    print(labelIndex)
                    return datesAsString[labelIndex]
                }
                
                self.chart.add(series)
                
                
                // Update the change labels
                
                self.graphChangeLabel.text = self.getTwoDecimals(number: String(describing: (last-first))) + "$"
                let percentChange = (last - first)/first*100
                self.graphChangePCTLabel.text = self.getTwoDecimals(number: String(describing: percentChange)) + "%"
                self.graphTopLabel.text = self.getTwoDecimals(number: String(describing: top)) + "$"
                self.graphBottomLabel.text = self.getTwoDecimals(number: String(describing: bottom)) + "$"
            }
            
        })
        
        
    }
    
    func updateChart1Week() -> Void {
        // Remove everything at first.
        
        var first = 0.0
        var last = 0.0
        var top = 0.0
        var bottom = 0.0
        var pointCounter = 0
        
        // Need to get a json object
        let parser = Parser()
        let url = getChartRequestURL(typeOfRequest:"hour", aggregate:3, limit:56)
        parser.networkRequest(APICall: url, completion: { (success) -> Void in
            self.chart.removeAllSeries()
            var raw = success["Data"]
            //var conversion = raw[self.coin] as! [String:Any]
            //self.labels = conversion[self.favoriteCurrency] as! [String:Any]
            //var raw = success["Data"] as! [String:Any]
            //print(success)
            //print(raw)
            print(type(of: success["Data"]))
            
            var test = raw as! NSArray
            print(test[1])
            //self.updateLabels(labels: self.labels)
            
            var dates:[Date] = []
            var datesAsString:[String] = []
            var dataPoints:[(x:(Float), y:(Float))] = []
            print(type(of: test[1]))
            var counter:Double = 0
            
            // lastDateString
            var lastDateString:String = ""
            
            
            
            for point in test{
                
                //print(type(of: point))
                var dataPoint = point as! Dictionary<String, Any>
                //print(dataPoint["time"])
                
                //let date = Date(timeIntervalSince1970: timeStamp)
                //print(date)
                //dates.append(date)
                
                if let t = dataPoint["time"] {
                    let timeStamp = dataPoint["time"] as! Double
                    let date = Date(timeIntervalSince1970: timeStamp)
                    //print(date)
                    dates.append(date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM"
                    let dateString = dateFormatter.string(from: date)
                    
                    
                    
                    if let date = dateFormatter.date(from: dateString) {
                        
                        dateFormatter.dateFormat = "MM"
                        print("Month is \(dateFormatter.string(from: date))")
                        let m = dateFormatter.string(from: date)
                        dateFormatter.dateFormat = "dd"
                        print("date is \(dateFormatter.string(from: date))")
                        let d = dateFormatter.string(from: date)
                        
                        let newDate = m + "/" + d
                        
                        
                        if (datesAsString.count == 0 || datesAsString.last != newDate) {
                            //labels.append(Float(i))
                            datesAsString.append(newDate)
                            
                        }
                        
                    }
                }else{
                    print("Something is not right.")
                }
                if let t = dataPoint["close"]{
                    let k = t as! Double
                    
                    dataPoints.append(((x:Float(counter), y: Float(k))))
                    
                    // Get the other datapoints
                    if pointCounter == 0{
                        first = k
                        top = k
                        bottom = k
                    }
                    last = k
                    
                    // Top
                    if k > top {
                        top = k
                    }
                    
                    // Bottom
                    if k < bottom {
                        bottom = k
                    }
                    pointCounter = pointCounter + 1
                }else{
                    print("Something is not right1.")
                }
                
                counter = counter + 0.125
            }
            
            DispatchQueue.main.async() {
                
                let series = ChartSeries([Float(0)])
                //series.data = []
                series.data = dataPoints
                
                print(dataPoints.count)
                self.chart.xLabels = [0,1,2,3,4,5,6,7]
                self.chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
                    return datesAsString[labelIndex]
                }
                
                self.chart.add(series)
                
                // Update the change labels
                
                self.graphChangeLabel.text = self.getTwoDecimals(number: String(describing: (last-first))) + "$"
                let percentChange = (last - first)/first*100
                self.graphChangePCTLabel.text = self.getTwoDecimals(number: String(describing: percentChange)) + "%"
                self.graphTopLabel.text = self.getTwoDecimals(number: String(describing: top)) + "$"
                self.graphBottomLabel.text = self.getTwoDecimals(number: String(describing: bottom)) + "$"
            }
            
        })
        
        
    }
    
    func updateChart1Month() -> Void {
        // Remove everything at first.
        
        var first = 0.0
        var last = 0.0
        var top = 0.0
        var bottom = 0.0
        var pointCounter = 0
        
    
        
        // Need to get a json object
        let parser = Parser()
        let url = getChartRequestURL(typeOfRequest:"hour", aggregate:5, limit:160)
        parser.networkRequest(APICall: url, completion: { (success) -> Void in
            self.chart.removeAllSeries()
            var raw = success["Data"]
            //var conversion = raw[self.coin] as! [String:Any]
            //self.labels = conversion[self.favoriteCurrency] as! [String:Any]
            //var raw = success["Data"] as! [String:Any]
            //print(success)
            //print(raw)
            print(type(of: success["Data"]))
            
            var test = raw as! NSArray
            print(test[1])
            //self.updateLabels(labels: self.labels)
            
            var dates:[Date] = []
            var datesAsString:[String] = []
            var dataPoints:[(x:(Float), y:(Float))] = []
            print(type(of: test[1]))
            var counter:Float = 0
            
            // lastDateString
            var lastDateString:String = ""
            
            var labelCounter:Int = 0
            
            for point in test{
                //print(type(of: point))
                var dataPoint = point as! Dictionary<String, Any>
                //print(dataPoint["time"])
                
                //let date = Date(timeIntervalSince1970: timeStamp)
                //print(date)
                //dates.append(date)
                
                if let t = dataPoint["time"] {
                    let timeStamp = dataPoint["time"] as! Double
                    let date = Date(timeIntervalSince1970: timeStamp)
                    //print(date)
                    dates.append(date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM"
                    let dateString = dateFormatter.string(from: date)
                    
                    
                    
                    if let date = dateFormatter.date(from: dateString) {
                        
                        dateFormatter.dateFormat = "MM"
                        print("Month is \(dateFormatter.string(from: date))")
                        let m = dateFormatter.string(from: date)
                        dateFormatter.dateFormat = "dd"
                        print("date is \(dateFormatter.string(from: date))")
                        let d = dateFormatter.string(from: date)
                        
                        let newDate = m + "/" + d
                        
                        
                        
                        
                        
                            if (labelCounter == 35){
                                //labels.append(Float(i))
                                datesAsString.append(newDate)
                                lastDateString = newDate
                                labelCounter = 0
                            }else{
                                labelCounter = labelCounter + 1
                            }
                        
                    }
                }else{
                    print("Something is not right.")
                }
                if let t = dataPoint["close"]{
                    let k = t as! Double
                    
                    dataPoints.append(((x:Float(counter), y: Float(k))))
                    
                    // Get the other datapoints
                    if pointCounter == 0{
                        first = k
                        top = k
                        bottom = k
                    }
                    last = k
                    
                    // Top
                    if k > top {
                        top = k
                    }
                    
                    // Bottom
                    if k < bottom {
                        bottom = k
                    }
                    pointCounter = pointCounter + 1
                    
                }else{
                    print("Something is not right1.")
                }
                
                counter = counter + 0.025
                print("Counter: " + String(describing: counter))
                print("Count of datesAsString: " + String(describing: datesAsString.count))
            }
            
            DispatchQueue.main.async() {
                
                let series = ChartSeries([Float(0)])
                //series.data = []
                series.data = dataPoints
                
                print(dataPoints.count)
                self.chart.xLabels = [0,1,2,3]
                self.chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
                    print(labelIndex)
                    return datesAsString[labelIndex]
                }
                
                self.chart.add(series)
                
                // Update the change labels
                
                self.graphChangeLabel.text = self.getTwoDecimals(number: String(describing: (last-first))) + "$"
                let percentChange = (last - first)/first*100
                self.graphChangePCTLabel.text = self.getTwoDecimals(number: String(describing: percentChange)) + "%"
                self.graphTopLabel.text = self.getTwoDecimals(number: String(describing: top)) + "$"
                self.graphBottomLabel.text = self.getTwoDecimals(number: String(describing: bottom)) + "$"
                
            }
            
        })
        
        
    }
    
    func updateChart3Months() -> Void {
        // Remove everything at first.
        
        
        var first = 0.0
        var last = 0.0
        var top = 0.0
        var bottom = 0.0
        var pointCounter = 0
        
        
        // Need to get a json object
        let parser = Parser()
        let url = getChartRequestURL(typeOfRequest:"hour", aggregate:12, limit:200)
        parser.networkRequest(APICall: url, completion: { (success) -> Void in
            self.chart.removeAllSeries()
            var raw = success["Data"]
            //var conversion = raw[self.coin] as! [String:Any]
            //self.labels = conversion[self.favoriteCurrency] as! [String:Any]
            //var raw = success["Data"] as! [String:Any]
            //print(success)
            //print(raw)
            print(type(of: success["Data"]))
            
            var test = raw as! NSArray
            print(test[1])
            //self.updateLabels(labels: self.labels)
            
            var dates:[Date] = []
            var datesAsString:[String] = []
            var dataPoints:[(x:(Float), y:(Float))] = []
            print(type(of: test[1]))
            var counter:Float = 0
            
            // lastDateString
            var lastDateString:String = ""
            
            var labelCounter:Int = 0
            
            for point in test{
                //print(type(of: point))
                var dataPoint = point as! Dictionary<String, Any>
                //print(dataPoint["time"])
                
                //let date = Date(timeIntervalSince1970: timeStamp)
                //print(date)
                //dates.append(date)
                
                if let t = dataPoint["time"] {
                    let timeStamp = dataPoint["time"] as! Double
                    let date = Date(timeIntervalSince1970: timeStamp)
                    //print(date)
                    dates.append(date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM"
                    let dateString = dateFormatter.string(from: date)
                    
                    
                    
                    if let date = dateFormatter.date(from: dateString) {
                        
                        dateFormatter.dateFormat = "MM"
                        print("Month is \(dateFormatter.string(from: date))")
                        let m = dateFormatter.string(from: date)
                        dateFormatter.dateFormat = "dd"
                        print("date is \(dateFormatter.string(from: date))")
                        let d = dateFormatter.string(from: date)
                        
                        let newDate = m + "/" + d
                        
                        
                        
                        if (datesAsString.count == 0) {
                            datesAsString.append(newDate)
                            lastDateString = newDate
                            labelCounter = labelCounter + 1
                        }
                        
                        if (labelCounter == 50){
                            //labels.append(Float(i))
                            datesAsString.append(newDate)
                            lastDateString = newDate
                            labelCounter = 0
                        }else{
                            labelCounter = labelCounter + 1
                        }
                        
                    }
                }else{
                    print("Something is not right.")
                }
                if let t = dataPoint["close"]{
                    let k = t as! Double
                    
                    dataPoints.append(((x:Float(counter), y: Float(k))))
                    
                    // Get the other datapoints
                    if pointCounter == 0{
                        first = k
                        top = k
                        bottom = k
                    }
                    last = k
                    
                    // Top
                    if k > top {
                        top = k
                    }
                    
                    // Bottom
                    if k < bottom {
                        bottom = k
                    }
                    pointCounter = pointCounter + 1
                    
                }else{
                    print("Something is not right1.")
                }
                
                counter = counter + 0.02
                print("Counter: " + String(describing: counter))
                print("Count of datesAsString: " + String(describing: datesAsString.count))
            }
            
            DispatchQueue.main.async() {
                
                let series = ChartSeries([Float(0)])
                //series.data = []
                series.data = dataPoints
                
                print(dataPoints.count)
                self.chart.xLabels = [0,1,2,3]
                self.chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
                    print(labelIndex)
                    return datesAsString[labelIndex]
                }
                
                self.chart.add(series)
                
                
                // Update the change labels
                
                self.graphChangeLabel.text = self.getTwoDecimals(number: String(describing: (last-first))) + "$"
                let percentChange = (last - first)/first*100
                self.graphChangePCTLabel.text = self.getTwoDecimals(number: String(describing: percentChange)) + "%"
                self.graphTopLabel.text = self.getTwoDecimals(number: String(describing: top)) + "$"
                self.graphBottomLabel.text = self.getTwoDecimals(number: String(describing: bottom)) + "$"
            }
            
        })
        
        
    }
    
    func updateChart6Months() -> Void {
        // Remove everything at first.
        
        var first = 0.0
        var last = 0.0
        var top = 0.0
        var bottom = 0.0
        var pointCounter = 0
        
        
        //let data = [(x: Float(0), y: Float(0)), (x: Float(0.5), y: Float(3.1))]
        //let data: Array<Float> = [0.0,  -2.70548,  -2.63699,  3.09075,  -3.05268, 0.0, 4.44349, 1.0, 0.0, -1.30397, 0.0, 0.0, 1.64384, -3.17637, 4.92295, -1.89212, -3.44178, -4.09326, 0.0, 2.06336, -2.5, 2.74829, -4.8532, 1.4726, -2.32021, 0.0, 0.0, -4.375, 4.10663, -0.821326, -1.77233, 1.73801]
        //let series = ChartSeries(data)
        // Create a new series specifying x and y values
        
        
        
        // Need to get a json object
        let parser = Parser()
        let url = getChartRequestURL(typeOfRequest:"day", aggregate:1, limit:180)
        parser.networkRequest(APICall: url, completion: { (success) -> Void in
            self.chart.removeAllSeries()
            var raw = success["Data"]
            //var conversion = raw[self.coin] as! [String:Any]
            //self.labels = conversion[self.favoriteCurrency] as! [String:Any]
            //var raw = success["Data"] as! [String:Any]
            //print(success)
            //print(raw)
            print(type(of: success["Data"]))
            
            var test = raw as! NSArray
            print(test[1])
            //self.updateLabels(labels: self.labels)
            
            var dates:[Date] = []
            var datesAsString:[String] = []
            var dataPoints:[(x:(Float), y:(Float))] = []
            print(type(of: test[1]))
            var counter:Float = 0
            
            // lastDateString
            var lastDateString:String = ""
            
            var labelCounter:Int = 0
            
            for point in test{
                //print(type(of: point))
                var dataPoint = point as! Dictionary<String, Any>
                //print(dataPoint["time"])
                
                //let date = Date(timeIntervalSince1970: timeStamp)
                //print(date)
                //dates.append(date)
                
                if let t = dataPoint["time"] {
                    let timeStamp = dataPoint["time"] as! Double
                    let date = Date(timeIntervalSince1970: timeStamp)
                    //print(date)
                    dates.append(date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM"
                    let dateString = dateFormatter.string(from: date)
                    
                    
                    
                    if let date = dateFormatter.date(from: dateString) {
                        
                        dateFormatter.dateFormat = "MMM"
                        print("Month is \(dateFormatter.string(from: date))")
                        let m = dateFormatter.string(from: date)
                        dateFormatter.dateFormat = "dd"
                        print("date is \(dateFormatter.string(from: date))")
                        let d = dateFormatter.string(from: date)
                        
                        let newDate = m + "/" + d
                        print(newDate)
                        
                        if (datesAsString.count == 0 || datesAsString.last != m) {
                            //datesAsString.append(Float(i))
                            datesAsString.append(m)
                        }
                        /*
                        
                        if (datesAsString.count == 0) {
                            datesAsString.append(newDate)
                            lastDateString = newDate
                            labelCounter = labelCounter + 1
                        }
                        
                        if (labelCounter == 50){
                            //labels.append(Float(i))
                            datesAsString.append(newDate)
                            lastDateString = newDate
                            labelCounter = 0
                        }else{
                            labelCounter = labelCounter + 1
                        }
 */
                        
                    }
                }else{
                    print("Something is not right.")
                }
                if let t = dataPoint["close"]{
                    let k = t as! Double
                    
                    dataPoints.append(((x:Float(counter), y: Float(k))))
                    
                    // Get the other datapoints
                    if pointCounter == 0{
                        first = k
                        top = k
                        bottom = k
                    }
                    last = k
                    
                    // Top
                    if k > top {
                        top = k
                    }
                    
                    // Bottom
                    if k < bottom {
                        bottom = k
                    }
                    pointCounter = pointCounter + 1
                    
                }else{
                    print("Something is not right1.")
                }
                
                counter = counter + 0.033333
                print("Counter: " + String(describing: counter))
                print("Count of datesAsString: " + String(describing: datesAsString.count))
            }
            
            DispatchQueue.main.async() {
                
                let series = ChartSeries([Float(0)])
                //series.data = []
                series.data = dataPoints
                
                print(dataPoints.count)
                self.chart.xLabels = [0,1,2,3,4,5]
                self.chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
                    print(labelIndex)
                    return datesAsString[labelIndex]
                }
                
                self.chart.add(series)
                
                // Update the change labels
                
                self.graphChangeLabel.text = self.getTwoDecimals(number: String(describing: (last-first))) + "$"
                let percentChange = (last - first)/first*100
                self.graphChangePCTLabel.text = self.getTwoDecimals(number: String(describing: percentChange)) + "%"
                self.graphTopLabel.text = self.getTwoDecimals(number: String(describing: top)) + "$"
                self.graphBottomLabel.text = self.getTwoDecimals(number: String(describing: bottom)) + "$"
            }
            
        })
        
        
    }
    
    func updateChart12Months() -> Void {
        // Remove everything at first.
        
        var first = 0.0
        var last = 0.0
        var top = 0.0
        var bottom = 0.0
        var pointCounter = 0
        
        // Need to get a json object
        let parser = Parser()
        let url = getChartRequestURL(typeOfRequest:"day", aggregate:1, limit:360)
        parser.networkRequest(APICall: url, completion: { (success) -> Void in
            self.chart.removeAllSeries()
            var raw = success["Data"]
            
            
            
            var test = raw as! NSArray
            
            //self.updateLabels(labels: self.labels)
            
            var dates:[Date] = []
            var datesAsString:[String] = []
            var dataPoints:[(x:(Float), y:(Float))] = []
            print(type(of: test[1]))
            var counter:Float = 0
            
            // lastDateString
            var lastDateString:String = ""
            
            var labelCounter:Int = 0
            
            for point in test{
                //print(type(of: point))
                var dataPoint = point as! Dictionary<String, Any>
                //print(dataPoint["time"])
                
                //let date = Date(timeIntervalSince1970: timeStamp)
                //print(date)
                //dates.append(date)
                
                if let t = dataPoint["time"] {
                    let timeStamp = dataPoint["time"] as! Double
                    let date = Date(timeIntervalSince1970: timeStamp)
                    //print(date)
                    dates.append(date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM"
                    let dateString = dateFormatter.string(from: date)
                    
                    
                    
                    if let date = dateFormatter.date(from: dateString) {
                        
                        dateFormatter.dateFormat = "MMM"
                        print("Month is \(dateFormatter.string(from: date))")
                        let m = dateFormatter.string(from: date)
                        dateFormatter.dateFormat = "dd"
                        print("date is \(dateFormatter.string(from: date))")
                        let d = dateFormatter.string(from: date)
                        
                        let newDate = m + "/" + d
                        print(newDate)
                        
                        if (datesAsString.count == 0 || datesAsString.last != m) {
                            //datesAsString.append(Float(i))
                            
                            if (datesAsString.count == 0){
                                print("NEW DATESTRING ADDED!!!!!")
                                datesAsString.append(m)
                                labelCounter = 0
                            }
                            
                            if (labelCounter == 90){
                                print("NEW DATESTRING ADDED!!!!!")
                                datesAsString.append(m)
                                labelCounter = 0
                            }else{
                                labelCounter = labelCounter + 1
                            }
                            
                        }
                        /*
                         
                         if (datesAsString.count == 0) {
                         datesAsString.append(newDate)
                         lastDateString = newDate
                         labelCounter = labelCounter + 1
                         }
                         
                         if (labelCounter == 50){
                         //labels.append(Float(i))
                         datesAsString.append(newDate)
                         lastDateString = newDate
                         labelCounter = 0
                         }else{
                         labelCounter = labelCounter + 1
                         }
                         */
                        
                    }
                }else{
                    print("Something is not right.")
                }
                if let t = dataPoint["close"]{
                    let k = t as! Double
                    
                    dataPoints.append(((x:Float(counter), y: Float(k))))
                    
                    // Get the other datapoints
                    if pointCounter == 0{
                        first = k
                        top = k
                        bottom = k
                    }
                    last = k
                    
                    // Top
                    if k > top {
                        top = k
                    }
                    
                    // Bottom
                    if k < bottom {
                        bottom = k
                    }
                    pointCounter = pointCounter + 1
                    
                }else{
                    print("Something is not right1.")
                }
                
                counter = counter + 0.01111111
                print("Counter: " + String(describing: counter))
                print("Count of datesAsString: " + String(describing: datesAsString.count))
            }
            
            DispatchQueue.main.async() {
                
                let series = ChartSeries([Float(0)])
                //series.data = []
                series.data = dataPoints
                
                print(dataPoints.count)
                self.chart.xLabels = [0,1,2,3]
                self.chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
                    print(labelIndex)
                    return datesAsString[labelIndex]
                }
                
                self.chart.add(series)
                
                
                // Update the change labels
                
                self.graphChangeLabel.text = self.getTwoDecimals(number: String(describing: (last-first))) + "$"
                let percentChange = (last - first)/first*100
                self.graphChangePCTLabel.text = self.getTwoDecimals(number: String(describing: percentChange)) + "%"
                self.graphTopLabel.text = self.getTwoDecimals(number: String(describing: top)) + "$"
                self.graphBottomLabel.text = self.getTwoDecimals(number: String(describing: bottom)) + "$"
                
            }
            
        })
        
        
    }
    
    func updateChartAll() -> Void {
        // Remove everything at first.
        
        var first = 0.0
        var last = 0.0
        var top = 0.0
        var bottom = 0.0
        var pointCounter = 0
        
        
        //let data = [(x: Float(0), y: Float(0)), (x: Float(0.5), y: Float(3.1))]
        //let data: Array<Float> = [0.0,  -2.70548,  -2.63699,  3.09075,  -3.05268, 0.0, 4.44349, 1.0, 0.0, -1.30397, 0.0, 0.0, 1.64384, -3.17637, 4.92295, -1.89212, -3.44178, -4.09326, 0.0, 2.06336, -2.5, 2.74829, -4.8532, 1.4726, -2.32021, 0.0, 0.0, -4.375, 4.10663, -0.821326, -1.77233, 1.73801]
        //let series = ChartSeries(data)
        // Create a new series specifying x and y values
        
        
        
        // Need to get a json object
        let parser = Parser()
        let url = getChartRequestURL(typeOfRequest:"day", aggregate:20, limit:100)
        parser.networkRequest(APICall: url, completion: { (success) -> Void in
            self.chart.removeAllSeries()
            var raw = success["Data"]
            //var conversion = raw[self.coin] as! [String:Any]
            //self.labels = conversion[self.favoriteCurrency] as! [String:Any]
            //var raw = success["Data"] as! [String:Any]
            //print(success)
            //print(raw)
            print(type(of: success["Data"]))
            
            var test = raw as! NSArray
            print(test[1])
            //self.updateLabels(labels: self.labels)
            
            var dates:[Date] = []
            var datesAsString:[String] = []
            var dataPoints:[(x:(Float), y:(Float))] = []
            print(type(of: test[1]))
            var counter:Float = 0
            
            // lastDateString
            var lastDateString:String = ""
            
            var labelCounter:Int = 0
            
            for point in test{
                //print(type(of: point))
                var dataPoint = point as! Dictionary<String, Any>

                
                if let t = dataPoint["time"] {
                    let timeStamp = dataPoint["time"] as! Double
                    let date = Date(timeIntervalSince1970: timeStamp)
                    //print(date)
                    dates.append(date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yy"
                    let dateString = dateFormatter.string(from: date)
                    
                    
                    
                    if let date = dateFormatter.date(from: dateString) {
                        
                        dateFormatter.dateFormat = "MMM-yy"
                        
                        let m = dateFormatter.string(from: date)
                        //dateFormatter.dateFormat = "dd"
                        //print("date is \(dateFormatter.string(from: date))")
                        //let d = dateFormatter.string(from: date)
                        
                        let newDate = m
                        
                        
                        if (datesAsString.count == 0 || datesAsString.last != m) {
                            //datesAsString.append(Float(i))
                            
                            if (datesAsString.count == 0){
                                print("NEW DATESTRING ADDED!!!!!")
                                datesAsString.append(m)
                                labelCounter = 0
                            }
                            
                            if (labelCounter == 25){
                                print("NEW DATESTRING ADDED!!!!!")
                                datesAsString.append(m)
                                labelCounter = 0
                            }else{
                                labelCounter = labelCounter + 1
                            }
                            
                        }
                        
                    }
                }else{
                    print("Something is not right.")
                }
                if let t = dataPoint["close"]{
                    let k = t as! Double
                    
                    dataPoints.append(((x:Float(counter), y: Float(k))))
                    
                    // Get the other datapoints
                    if pointCounter == 0{
                        first = k
                        top = k
                        bottom = k
                    }
                    last = k
                    
                    // Top
                    if k > top {
                        top = k
                    }
                    
                    // Bottom
                    if k < bottom {
                        bottom = k
                    }
                    pointCounter = pointCounter + 1
                    
                }else{
                    print("Something is not right1.")
                }
                
                counter = counter + 0.04
                print("Counter: " + String(describing: counter))
                print("Count of datesAsString: " + String(describing: datesAsString.count))
            }
            
            DispatchQueue.main.async() {
                
                let series = ChartSeries([Float(0)])
                //series.data = []
                series.data = dataPoints
                
                print(dataPoints.count)
                self.chart.xLabels = [0,1,2,3]
                self.chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
                    print(labelIndex)
                    return datesAsString[labelIndex]
                }
                
                self.chart.add(series)
                
                
                // Update the change labels
                
                self.graphChangeLabel.text = self.getTwoDecimals(number: String(describing: (last-first))) + "$"
                let percentChange = (last - first)/first*100
                self.graphChangePCTLabel.text = self.getTwoDecimals(number: String(describing: percentChange)) + "%"
                self.graphTopLabel.text = self.getTwoDecimals(number: String(describing: top)) + "$"
                self.graphBottomLabel.text = self.getTwoDecimals(number: String(describing: bottom)) + "$"
            }
            
        })
        
        
    }
    
    func getChartRequestURL(typeOfRequest:String, aggregate: Int, limit: Int) -> String {
        // Type can be: Minute, Hour, Day
        //return "https://min-api.cryptocompare.com/data/histoday?fsym=" + coin + "&tsym=USD&limit=7&aggregate=1&e=CCCAGG"
        return "https://min-api.cryptocompare.com/data/histo" + typeOfRequest + "?fsym=" + coin + "&tsym=USD&limit=" + String(describing: limit) + "&aggregate=" + String(describing: aggregate) + "&e=CCCAGG"
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
    
    func updateUSDPriceLabels(){
        // Get the URL to update
        let usdPriceRequestURL = getUSDRequestURL()
        // Access the data
        let parser = Parser()
        
        parser.networkRequest(APICall: usdPriceRequestURL) { (success) -> Void in
            //let raw = success["RAW"] as! [String:Any]
            //let conversion = raw[self.coin] as! [String:Any]
            //print(conversion)
            let theUSDPrice = success["USD"] as! Double
            print("THIS IS THE PRICE OF USD " + String(describing: theUSDPrice))
            DispatchQueue.main.async() {
                self.usdPrice = theUSDPrice
                self.chartConversionPriceLabel.text = self.getTwoDecimals(number: String(describing: self.usdPrice)) + "$"
            }
            
            
        }
        // Update the labels on async
        
    }
    
    
    func getUSDRequestURL() -> String {
        return "https://min-api.cryptocompare.com/data/price?fsym=" + coin + "&tsyms=USD"
    }
    
    func getRequestURL() -> String {
        print("https://min-api.cryptocompare.com/data/pricemultifull?fsyms=" + coin + "&tsyms=" + favoriteCurrency)
        return "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=" + coin + "&tsyms=" + favoriteCurrency
    }
    
    /*
     This function is called to update the labels with the current price information.
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
        
        DispatchQueue.main.async() {
            self.conversionPriceLabel.text = self.getTwoDecimals(number: String(describing: labels["PRICE"]!)) + self.localCurrencySymbol
            
            print("CHANGE 24H: " + self.getTwoDecimals(number: String(describing: labels["CHANGE24HOUR"]!)) + self.localCurrencySymbol)
            self.changeLast24hLabel.text = self.getTwoDecimals(number: String(describing: labels["CHANGE24HOUR"]!)) + self.localCurrencySymbol
            
            if let changepct = labels["CHANGEPCT24HOUR"] {
                self.changeLast24HourPercent.text = self.getTwoDecimals(number: String(describing: changepct)) + "%"
            }else{
                self.changeLast24HourPercent.text = "-"
            }
            
            
            self.setColorOn24hChange(change: String(describing: labels["CHANGE24HOUR"]!))
            self.marketcapLabel.text = self.getTwoDecimals(number: String(describing: labels["MKTCAP"]!)) + self.localCurrencySymbol
            self.numberOfCoinsLabel.text = self.getZeroDecimals(number: String(describing: labels["SUPPLY"]!))
            //print(self.price)
            
            // Change Volume labels
            self.volume24HCoin.text = self.getTwoDecimals(number: String(describing: labels["VOLUME24HOUR"]!))
            self.volume24HLocal.text = self.getTwoDecimals(number: String(describing: labels["VOLUME24HOURTO"]!)) + self.localCurrencySymbol
            
            // Change 24H low/high labels
            self.high24HLabel.text = self.getTwoDecimals(number: String(describing: labels["HIGH24HOUR"]!)) + self.localCurrencySymbol
            self.low24HLabel.text = self.getTwoDecimals(number: String(describing: labels["LOW24HOUR"]!)) + self.localCurrencySymbol
        }
    }
    
    func getTwoDecimals(number:String) -> String {
        var intermediate = Double(number)
        var final = ""
        if let theIntermediate = intermediate {
            final = String(format: "%.2f", intermediate!)
        }
        
        if let myInteger = Double(final) {
            let myNumber = NSNumber(value:myInteger)
            var theFinal = formatter.string(from: myNumber)
            print("RETURNERER DENNE : \(theFinal)")
            return theFinal!
        }
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
        guard let theChange = changeInt else {
            return
        }
        
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
    
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        if(segmentedControl.selectedSegmentIndex == 0)
        {
            print("1H")
            updateChart1Hour()
        }
        else if(segmentedControl.selectedSegmentIndex == 1)
        {
            print("1D")
            updateChart1Day()
        }
        else if(segmentedControl.selectedSegmentIndex == 2)
        {
            print("1W")
            updateChart1Week()
        }
        else if(segmentedControl.selectedSegmentIndex == 3)
        {
            print("1M")
            updateChart1Month()
        }
        else if(segmentedControl.selectedSegmentIndex == 4)
        {
            print("3M")
            updateChart3Months()
        }
        else if(segmentedControl.selectedSegmentIndex == 5)
        {
            print("6M")
            updateChart6Months()
        }
        else if(segmentedControl.selectedSegmentIndex == 6)
        {
            print("1Y")
            updateChart12Months()
        }
        else if(segmentedControl.selectedSegmentIndex == 7)
        {
            print("All")
            updateChartAll()
        }
    }
    
    // Get Historical price information
    func getHistoricalData(length:Int, aggregate:Int) -> Void {
        // Create request.
    }
    
    
    // MARK: Chart delegate
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        // Do something on touch
        for (serieIndex, dataIndex) in indexes.enumerated() {
            if dataIndex != nil {
                // The series at serieIndex has been touched
                let value = chart.valueForSeries(serieIndex, atIndex: dataIndex)
                //print(chart.valueForSeries(Int(x), atIndex: dataIndex))
                //print(value)
                if let touchedValue = value {
                    /*
                     We need to figure out what change in percent is.
                     To calculate percentage decrease: First: work out the difference (decrease) between the two numbers you are comparing. Then: divide the decrease by the original number and multiply the answer by 100. If your answer is a negative number then this is a percentage increase.
                     */
                    //print(touchedValue)
                    //var letChangeBe = (usdPrice-Double(touchedValue))/usdPrice*100
                    var letChangeBe = (usdPrice-Double(touchedValue))/Double(touchedValue)*100
                    graphChangePercent.text = formatter.string(from: letChangeBe as NSNumber)! + "%"
                    graphLabel.text = formatter.string(from: touchedValue as NSNumber)! + "$"
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

