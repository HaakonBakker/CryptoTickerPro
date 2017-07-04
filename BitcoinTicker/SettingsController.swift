//
//  SettingsController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 27/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class SettingsController: UITableViewController, MFMailComposeViewControllerDelegate{
    
    @IBOutlet var localCurrencySymbol: UILabel!
    let defaults = UserDefaults.standard
    
    var wantToOnlyShowFavoriteCurrencies:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Observer for the view when it becomes active
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        // Setting the back button on the controller object
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        
        // Check favorites option
        wantToShowOnlyFavorites()
        
        // Updating the symbol that the user sees
        updateSymbol()
        
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        updateSymbol()
    }
    @objc override func viewDidAppear(_ animated: Bool) {
        print("SettingsView did appear")
        wantToShowOnlyFavorites()
        updateSymbol()
        
        self.tableView.reloadData()
    }
    
    func wantToShowOnlyFavorites(){
        
        // Find information about wanting to only show favorite
        if let favoritesOnly = self.defaults.object(forKey: "wantToShowOnlyFavorites") {
            wantToOnlyShowFavoriteCurrencies = favoritesOnly as! Bool
        }else{
            wantToOnlyShowFavoriteCurrencies = false
        }
        
        let ip = IndexPath(row: 2, section: 0)
        if let cell = tableView.cellForRow(at: ip as IndexPath) {
            if wantToOnlyShowFavoriteCurrencies{
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }
        
        
        
        tableView.reloadData()
    }
    
    func updateSymbol(){
        if let currencySymbol = self.defaults.object(forKey: "selectedCurrencySymbol") {
            print(currencySymbol)
            localCurrencySymbol.text = currencySymbol as! String
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Your action here
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        print(indexPath.section)
        print(indexPath.row)
        
        // Show only favorites
        if indexPath.section == 0 && indexPath.row == 2 {
            
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
                if cell.accessoryType == .checkmark{
                    cell.accessoryType = .none
                    wantToOnlyShowFavoriteCurrencies = false
                    defaults.set(wantToOnlyShowFavoriteCurrencies, forKey: "wantToShowOnlyFavorites")
                    // defaults.synchronize()
                    print("ONLY SHOW FAVORITES: False")
                }
                else{
                    cell.accessoryType = .checkmark
                    wantToOnlyShowFavoriteCurrencies = true
                    defaults.set(wantToOnlyShowFavoriteCurrencies, forKey: "wantToShowOnlyFavorites")
                    //defaults.synchronize()
                    print("ONLY SHOW FAVORITES: True")
                }
            }
        }
        
        // Share Cryptocurrency Pro
        if indexPath.section == 2 && indexPath.row == 0 {
            // Share the application with the function below
            shareApplication()
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            // Contact the developer
            openDeveloperTwitter()
        }
        
        // Open mail and contact the developer
        if indexPath.section == 2 && indexPath.row == 3 {
            // Contact the developer
            contactDeveloper()
        }
    }
    
    func openDeveloperTwitter() -> Void {
        UIApplication.shared.open(URL(string: "https://twitter.com/haakon_bakker")!, options: [:], completionHandler: nil)
    }
    
    func contactDeveloper(){
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Crypto Pro - Contact")
            mail.setToRecipients(["haakon@bakkertechnologies.com"])
            mail.setMessageBody("", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            print("Unable to send mail")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func shareApplication(){
        // text to share
        let text = "Hey! I'm using Cryptocurrency Pro, and you should too! Download the app here: LINK"
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }

}
