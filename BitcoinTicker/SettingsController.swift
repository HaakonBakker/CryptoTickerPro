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
import SafariServices

class SettingsController: UITableViewController, MFMailComposeViewControllerDelegate{
    
    @IBOutlet var localCurrencySymbol: UILabel!
    let defaults = UserDefaults.standard
    
    var wantToOnlyShowFavoriteCurrencies:Bool = false
    var wantToShowCoinAbbr:Bool = false
    var blackTheme:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blackTheme = defaults.bool(forKey: "blackTheme" )
        // Observer for the view when it becomes active
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        // Setting the back button on the controller object
//        self.navigationController?.navigationBar.tintColor = UIColor.white;
        
        // Check naming convention option
        wantToShowCoinAbbreviation()
        
        // Check favorites option
        wantToShowOnlyFavorites()
        
        // Updating the symbol that the user sees
        updateSymbol()
        
        setThemeColors()
        
        
    }
    
    func setThemeColors(){
        if blackTheme{
            self.navigationItem.backBarButtonItem?.tintColor = .white
            self.navigationController?.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.navigationController?.navigationBar.isTranslucent = false
            
            self.tableView.backgroundColor = UIColor.black
            
            
            self.tableView.separatorColor = #colorLiteral(red: 0.2510845065, green: 0.2560918033, blue: 0.2651863098, alpha: 1)
            
            self.tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            self.tabBarController?.tabBar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            // Gjør ingenting            UITabBar.appearance().barTintColor = UIColor.black
            
            tableView.reloadData()
        }else{
            // Is white theme
            self.navigationItem.backBarButtonItem?.tintColor = .white
            
            self.navigationController?.navigationBar.barStyle = .black
            
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            self.navigationController?.navigationBar.tintColor = .white
            
            self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            self.navigationController?.navigationBar.isTranslucent = true
            
            
            self.tableView.backgroundColor = UIColor.white
            
            
            self.tableView.separatorColor = UIColor(white: 0.97, alpha: 1)
            
            self.tabBarController?.tabBar.barTintColor = .white
            self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            self.tabBarController?.tabBar.backgroundColor = .white
            tableView.reloadData()
            tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
        }
    }
    
    
    
    @objc func applicationDidBecomeActive() {
        // handle event
        updateSymbol()
    }
    @objc override func viewDidAppear(_ animated: Bool) {
        print("SettingsView did appear")
        wantToShowOnlyFavorites()
        wantToShowCoinAbbreviation()
        updateSymbol()
        
        self.tableView.reloadData()
    }
    
    func wantToShowCoinAbbreviation(){
        // Find information about wanting to only show favorite
        if let abbrOnly = self.defaults.object(forKey: "wantToShowCoinAbbreviation") {
            wantToShowCoinAbbr = abbrOnly as! Bool
        }else{
            wantToShowCoinAbbr = false
        }
        print("Status: ", wantToShowCoinAbbr)
        let ip = IndexPath(row: 3, section: 0)
        if let cell = tableView.cellForRow(at: ip as IndexPath) {
            if wantToShowCoinAbbr{
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }
        
        tableView.reloadData()
    }
    
    func wantToShowOnlyFavorites(){
        
        // Find information about wanting to only show favorite
        if let favoritesOnly = self.defaults.object(forKey: "wantToShowOnlyFavorites") {
            wantToOnlyShowFavoriteCurrencies = favoritesOnly as! Bool
        }else{
            wantToOnlyShowFavoriteCurrencies = false
        }
        
        var ip = IndexPath(row: 2, section: 0)
        if let cell = tableView.cellForRow(at: ip as IndexPath) {
            if wantToOnlyShowFavoriteCurrencies{
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }
        
        
        // Find information about black theme
        
        ip = IndexPath(row: 4, section: 0)
        if let cell = tableView.cellForRow(at: ip as IndexPath) {
            if blackTheme{
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
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath){
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 && row == 0{
            if blackTheme{
                cell.detailTextLabel?.textColor = .lightGray
            }else{
                cell.detailTextLabel?.textColor = .darkGray
            }
        }
        
        if blackTheme{
            cell.backgroundColor = UIColor.clear
            
            cell.textLabel?.textColor = UIColor.white
            
            // Change the selected color of the cell when selected
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.2696416974, green: 0.2744067311, blue: 0.27892676, alpha: 1)
            cell.selectedBackgroundView = backgroundView
            
        }else{
            cell.backgroundColor = UIColor.clear
            
            cell.textLabel?.textColor = UIColor.black
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.selectedBackgroundView = backgroundView
        }
        
    }
    
    
    
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! UITableViewCell
//
//        var numbers = ["1","2","3","4","5","5","6","7","7","8","9"]
//        cell.textLabel!.text = numbers[indexPath.row]
//        cell.backgroundColor = UIColor.green
//
//        return cell
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let myBackButton = UIBarButtonItem()
//        myBackButton.title = "Settings"
//        navigationItem.backBarButtonItem = myBackButton
        self.navigationItem.backBarButtonItem?.tintColor = .white
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        
        // Changing the header for the tableview if the user wants the black theme
        if defaults.bool(forKey: "blackTheme" ){
            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
            header.contentView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0) //make the background color light blue
            header.textLabel?.textColor = UIColor.white //make the text white
            header.alpha = 1 //make the header white
        }else{
            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
            header.contentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            header.textLabel?.textColor = UIColor.black //make the text black
            header.alpha = 1 //make the header white
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Your action here
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        
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
        
        
        // Show coin abbriviation
        if indexPath.section == 0 && indexPath.row == 3 {
            
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
                if cell.accessoryType == .checkmark{
                    cell.accessoryType = .none
                    wantToOnlyShowFavoriteCurrencies = false
                    defaults.set(wantToOnlyShowFavoriteCurrencies, forKey: "wantToShowCoinAbbreviation")
                    // defaults.synchronize()
                    print("ONLY SHOW abbreviation: False")
                }
                else{
                    cell.accessoryType = .checkmark
                    wantToOnlyShowFavoriteCurrencies = true
                    defaults.set(wantToOnlyShowFavoriteCurrencies, forKey: "wantToShowCoinAbbreviation")
                    //defaults.synchronize()
                    
                    print("ONLY SHOW abbreviation: True")
                }
            }
        }
        
        // Show coin abbriviation
        if indexPath.section == 0 && indexPath.row == 4 {
            
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
                if cell.accessoryType == .checkmark{
                    cell.accessoryType = .none
                    blackTheme = false
                    defaults.set(blackTheme, forKey: "blackTheme")
                    // defaults.synchronize()
                    print("Black theme turned off")
                    setThemeColors()
                    tableView.reloadData()
                    
                    let textFieldAppearance = UITextField.appearance()
                    textFieldAppearance.keyboardAppearance = .default
                }
                else{
                    cell.accessoryType = .checkmark
                    blackTheme = true
                    defaults.set(blackTheme, forKey: "blackTheme")
                    //defaults.synchronize()
                    print("Black theme turned on")
                    setThemeColors()
                    tableView.reloadData()
                    
                    let textFieldAppearance = UITextField.appearance()
                    textFieldAppearance.keyboardAppearance = .dark //.default//.light//.alert
                }
            }
        }
        
        
        // Share Cryptocurrency Pro
        if indexPath.section == 2 && indexPath.row == 0 {
            // Share the application with the function below
            shareApplication()
        }
        
        //Open BT Website
        if indexPath.section == 1 && indexPath.row == 1 {
            openBTWebsite()
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            // Contact the developer
            openDeveloperTwitter()
        }
        
        // Open app in App Store
        if indexPath.section == 2 && indexPath.row == 2 {
            openAppInAppStore()
        }
        
        // Open mail and contact the developer
        if indexPath.section == 2 && indexPath.row == 3 {
            // Contact the developer
            contactDeveloper()
        }
        
    }
    
    func openAppInAppStore() -> Void {
        UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/crypto-ticker-pro/id1252973638?ls=1&mt=8")!, options: [:], completionHandler: nil)
    }
    
    func openDeveloperTwitter() -> Void {
        UIApplication.shared.open(URL(string: "https://twitter.com/haakon_bakker")!, options: [:], completionHandler: nil)
    }
    
    func openBTWebsite() -> Void {
            openURL(aURL: "https://www.bakkertechnologies.com?utm_source=CryptoTickerPro")
    }
    
    func openURL(aURL: String){
        let url = URL(string: aURL)!
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
    }
    
    func contactDeveloper(){
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Crypto Ticker Pro - Contact")
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
        let text = "Hey! I'm using Crypto Ticker Pro, and you should too! Download the app here: https://itunes.apple.com/app/crypto-ticker-pro/id1252973638?ls=1&mt=8"
        
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
