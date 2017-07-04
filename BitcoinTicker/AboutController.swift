//
//  AboutController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 27/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class AboutController: UIViewController{
    
    @IBOutlet var versionLabel: UILabel!
    
    // Button Actions
    
    @IBAction func openBakkerTech(_ sender: Any) {
        openURL(aURL: "https://www.bakkertechnologies.com")
    }
    @IBAction func openHaakonBakker(_ sender: Any) {
        openURL(aURL: "https://bakkertechnologies.com/om/")
    }
    @IBAction func openTerms(_ sender: Any) {
        //openURL(aURL: "https://bakkertechnologies.com/terms")
    }
    
    override func viewDidLoad() {
        if let aVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionLabel.text = version()
        }
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        //let build = dictionary["CFBundleVersion"] as! String
        return "\(version)" //" build \(build)"
    }
    
    
    
    func openURL(aURL: String){
        let url = URL(string: aURL)!
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
    }
}

