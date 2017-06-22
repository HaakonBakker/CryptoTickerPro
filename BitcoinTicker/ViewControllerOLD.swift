//
//  ViewController.swift
//  Bitcoin Ticker
//
//  Created by Haakon W Hoel Bakker on 29/05/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController {
    @IBOutlet var window: NSView!
    @IBOutlet weak var insideWindow: NSView!
    
    let APICoinDeskNOK = "http://api.coindesk.com/v1/bpi/currentprice/NOK.json"
    
    @IBOutlet weak var btcPrice: NSTextField!
    @IBOutlet weak var usdPrice: NSTextField!
    @IBOutlet weak var nokPrice: NSTextField!
    @IBOutlet weak var lastUpdatedTextField: NSTextField!
    @IBAction func refreshPressed(_ sender: Any) {
        getPrice()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let window = NSApplication.shared.windows.first else { return }
        //window.isOpaque = false
        //window.backgroundColor = .clear
        window.title = "Ticker"
        btcPrice.stringValue = "1"
        // Do any additional setup after loading the view.
        getPrice()
        
        
        
        
    }
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    func getPrice() -> Void {
        let parser = Parser()
        
        parser.networkRequest(APICall: APICoinDeskNOK, completion: { (success) -> Void in
            print("Second line of code executed")
            //print(success)
            
            // Get bpi numbers
            let bpiNumbers = success["bpi"] as! Dictionary<String,Any>
            
            // Get USD
            let usdNumbers = bpiNumbers["USD"] as! Dictionary<String,Any>
            self.usdPrice.stringValue = usdNumbers["rate"]! as! String
            print(usdNumbers)
            
            print(usdNumbers["rate"]!)
            
            
            
            
            // Get NOK
            let nokNumbers = bpiNumbers["NOK"] as! Dictionary<String,Any>
            self.nokPrice.stringValue = nokNumbers["rate"]! as! String
        })

        // Set updated time
        self.lastUpdatedTextField.stringValue = "Last Updated: " + self.getTimeString()

    }
    
    // Get today date as String
    
    func getTimeString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let hour = components.hour
        let minute = components.minute
        
        //let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        let time = String(hour!) + ":" + String(minute!)
        return time
        
    }
    

}


