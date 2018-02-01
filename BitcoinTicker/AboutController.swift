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
    let defaults = UserDefaults.standard
    
    
    // Labels
    @IBOutlet var appNameLabel: UILabel!
    
    @IBOutlet var versionStaticLabel: UILabel!
    @IBOutlet var developedStaticLabel: UILabel!
    @IBOutlet var websiteStaticLabel: UILabel!
    @IBOutlet var priceInfoFromStaticLabel: UILabel!
    @IBOutlet var apiStaticLabel: UILabel!
    
    @IBOutlet var versionLabel: UILabel!
    
    // Button Actions
    
    @IBAction func openBakkerTech(_ sender: Any) {
        openURL(aURL: "https://www.bakkertechnologies.com")
    }
    @IBAction func openHaakonBakker(_ sender: Any) {
        openURL(aURL: "https://bakkertechnologies.com/about/")
    }
    @IBAction func openTerms(_ sender: Any) {
        //openURL(aURL: "https://bakkertechnologies.com/terms")
    }
    
    override func viewDidLoad() {
        if let aVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionLabel.text = version()
        }
        setTheme()
    }
    
    func setTheme(){
        
        if defaults.bool(forKey: "blackTheme" ){
            view.backgroundColor = .black
            appNameLabel.textColor = .white
            
            versionStaticLabel.textColor = .white
            developedStaticLabel.textColor = .white
            websiteStaticLabel.textColor = .white
            priceInfoFromStaticLabel.textColor = .white
            apiStaticLabel.textColor = .white
            
            versionLabel.textColor = .white
        }else{
            view.backgroundColor = .white
            appNameLabel.textColor = .black
            
            versionStaticLabel.textColor = .black
            developedStaticLabel.textColor = .black
            websiteStaticLabel.textColor = .black
            priceInfoFromStaticLabel.textColor = .black
            apiStaticLabel.textColor = .black
            
            versionLabel.textColor = .black
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setTheme()
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

