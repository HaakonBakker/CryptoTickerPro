//
//  TableOfCryptocurrenciesController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 19/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class CryptocurrencyTableViewCell: UITableViewCell {
    
    //@IBOutlet strong var image: UIImageView!
    @IBOutlet weak var cryptoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    
    var baseAbbreviation:String?
}


class TableOfCryptocurrencies: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    //let cryptos = ["Bitcoin", "Ripple", "Litecoin", "Dogecoin"]
    //var personalFavorites = ["BTC", "ETH", "ETC", "LTC"]
    let textCellIdentifier = "TextCell"
    var cryptos:[Cryptocurrency]!
    
    var filteredCryptos = [Cryptocurrency]()
    var favoriteCryptos:[Cryptocurrency] = []
    var cryptoController:CryptoController!
    var refreshControl: UIRefreshControl!
    var data:([String], [Cryptocurrency])!
    var localCurrency:String = ""
    var highToLow:Bool!
    var selectedSortOption:String!
    
    var personalFavorites:[String]!
    let defaults = UserDefaults.standard
    // Buttons
    @IBOutlet weak var coinButton: UIBarButtonItem!
    @IBOutlet weak var priceButton: UIBarButtonItem!
    @IBOutlet weak var change24HButton: UIBarButtonItem!
    
    var wantToOnlyShowFavoriteCurrencies:Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    
    var lastUpdated:Date? = nil
    let formatter = NumberFormatter()
    
    
    @IBOutlet var sortBarButtonItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        // Testing
//        defaults.set(true, forKey: "blackTheme")
        
        
        highToLow = true
        selectedSortOption = "Mrkcap"
        sortBarButtonItem.title = "Mrkcap ↑"
        
        
        // Search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cryptos"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
//        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        // Changing the search bar on the white theme to be "normal" color
        if #available(iOS 11.0, *) {
            if defaults.bool(forKey: "blackTheme" ){

            }else{
                // Fixing white horizontal line above the search bar
                navigationController?.navigationBar.isTranslucent = false
                searchController.searchBar.tintColor = .white
                if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                    textfield.textColor = UIColor.blue
                    if let backgroundview = textfield.subviews.first {
                        
                        // Background color
                        backgroundview.backgroundColor = UIColor.white
                        
                        // Rounded corner
                        backgroundview.layer.cornerRadius = 10;
                        backgroundview.clipsToBounds = true;
                    }
                }
                
            }
        }
        
        
        
        
        
        
        
        // Set the formatter to decimal.
        formatter.numberStyle = NumberFormatter.Style.decimal
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        checkNetworkReachability()
        
        let start = NSDate(); // <<<<<<<<<< Start time
        super.viewDidLoad()
        
        
        
        cryptoController = CryptoController.sharedInstance
        // Do CryptoController setup
        cryptoController.tableOfCryptocurrencies = self
        cryptoController.updatePrice()
        
        
        cryptos = cryptoController.getCurrencies()
        
        
        // Get favorite only status
        wantToShowOnlyFavorites()
        
        // Get favorite coins
        getFavorites()
        
        
        // Will need to remove the favorites and store them in a separate array

//        for fav in personalFavorites{
//            var coin:Cryptocurrency
//
//            if let index = cryptos.index(where: {$0.baseAbbriviation == fav}) {
//                coin = cryptos.remove(at: index)
//                favoriteCryptos.append(coin)
//            }
//
//        }
        
        
        //self.tableView.register(CryptocurrencyTableViewCell.self, forCellReuseIdentifier: "TextCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if defaults.bool(forKey: "hasBeenOpenedBefore" ){
            cryptos.sort { $0.mrkCap > $1.mrkCap }
        }else{
            cryptos.sort { $0.baseCurrency < $1.baseCurrency }
            sortBarButtonItem.title = "Name ↓"
            defaults.set(true, forKey: "hasBeenOpenedBefore")
            
        }
        cryptos.sort { $0.mrkCap > $1.mrkCap }
        tableView.reloadData()
        
        setTheme()
        
        
        
        // TIMER END
        let end = NSDate();   // <<<<<<<<<<   end time
        let timeInterval: Double = end.timeIntervalSince(start as Date); // <<<<< Difference in seconds (double)
        print("Time to load viewDidLoad: \(timeInterval) seconds")
        
        // Observer for the view when it becomes active
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh - Last updated: " + getLastUpdateTime(), attributes: [NSForegroundColorAttributeName: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)])
        
        refreshControl.addTarget(self, action: #selector(TableOfCryptocurrencies.refreshPull), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        
        // Sort the tableview while loading
        isTop = true
//        sortTableViewCoin(isSortedOnTop: isTop)
        
        
        
        if defaults.bool(forKey: "blackTheme" ){
            let textFieldAppearance = UITextField.appearance()
            textFieldAppearance.keyboardAppearance = .dark //.default//.light//.alert
        }
        
        cryptos.sort { $0.mrkCap > $1.mrkCap }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        setTheme()
    }
    
    func setTheme(){
        if defaults.bool(forKey: "blackTheme" ){
            self.navigationController?.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.navigationController?.navigationBar.isTranslucent = false
            
            
            self.tableView.backgroundColor = UIColor.black
            
            
            self.tableView.separatorColor = #colorLiteral(red: 0.2510845065, green: 0.2560918033, blue: 0.2651863098, alpha: 1)
            
            self.tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            self.tabBarController?.tabBar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.tabBarController?.tabBar.isTranslucent = false
            // Gjør ingenting            UITabBar.appearance().barTintColor = UIColor.black
            
            
//            navigationController?.navigationBar.isTranslucent = false
//            searchController.searchBar.tintColor = .white
//            if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
//                textfield.textColor = UIColor.blue
//                if let backgroundview = textfield.subviews.first {
//
//                    // Background color
//                    backgroundview.backgroundColor = UIColor.white
//
//                    // Rounded corner
//                    backgroundview.layer.cornerRadius = 10;
//                    backgroundview.clipsToBounds = true;
//                }
//            }
            
            searchController.searchBar.tintColor = .black
            if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.darkGray
                let textFieldInsideUISearchBarLabel = textfield.value(forKey: "placeholderLabel") as? UILabel
                textFieldInsideUISearchBarLabel?.textColor = UIColor.gray
                
                
                // Glass Icon Customization
                let glassIconView = textfield.leftView as? UIImageView
                glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
                glassIconView?.tintColor = UIColor.black
                
                
                
                // Clear Button Customization
                let clearButton = textfield.value(forKey: "clearButton") as! UIButton
                clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                clearButton.tintColor = UIColor.gray
                
                let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
                UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
                
                if let backgroundview = textfield.subviews.first {
                    
                    // Background color
                    backgroundview.backgroundColor = UIColor.white
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10;
                    backgroundview.clipsToBounds = true;
                }
            }
            
            
        }else{
            // Is white theme
            self.navigationController?.navigationBar.barStyle = .black
            
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            self.navigationController?.navigationBar.isTranslucent = false
            
            
            self.tableView.backgroundColor = UIColor.white
            
            
            self.tableView.separatorColor = #colorLiteral(red: 0.8243665099, green: 0.8215891719, blue: 0.8374734521, alpha: 1)
//            UIColor(white: 0.97, alpha: 1)
            
            self.tabBarController?.tabBar.barTintColor = .white
            self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.3411764706, green: 0.5098039216, blue: 0.7333333333, alpha: 1)
            self.tabBarController?.tabBar.backgroundColor = .white
            
            searchController.searchBar.tintColor = .white
            if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.darkGray
                let textFieldInsideUISearchBarLabel = textfield.value(forKey: "placeholderLabel") as? UILabel
                textFieldInsideUISearchBarLabel?.textColor = UIColor.gray
                
                
                // Glass Icon Customization
                let glassIconView = textfield.leftView as? UIImageView
                glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
                glassIconView?.tintColor = UIColor.black
                
                
                
                // Clear Button Customization
                let clearButton = textfield.value(forKey: "clearButton") as! UIButton
                clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                clearButton.tintColor = UIColor.gray
                
                
                if let backgroundview = textfield.subviews.first {
                    
                    // Background color
                    backgroundview.backgroundColor = UIColor.white
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10;
                    backgroundview.clipsToBounds = true;
                }
            }
            
            tableView.reloadData()
        }
    }
    
    
    
    @IBAction func sortButtonAction(_ sender: Any) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as! SortPopoverViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.cryptoTableView = self
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.barButtonItem = sender as! UIBarButtonItem
        popover.delegate = vc as! UIPopoverPresentationControllerDelegate
        present(vc, animated: true, completion:nil)
    
        
        
        
        
////        self.performSegue(withIdentifier: "sortPopover", sender: self)
//        cryptos.sort { $0.mrkCap > $1.mrkCap }
//        print("Sorted by mrkcap")
//        self.tableView.reloadData()
    }
    
    
    
    
    
    func getLastUpdateTime() -> String {
        if let lastUpdatedDefault = self.defaults.object(forKey: "lastUpdated") {
            lastUpdated = lastUpdatedDefault as! Date
        }else{
            lastUpdated = nil
            return "N/A"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        let dateString = dateFormatter.string(from: lastUpdated!)
//        print(dateString)
        
        
        return dateString
    }
    
    func setLastUpdateTime() -> Void {
        var date = Date()
//        print(date)
        defaults.set(date, forKey: "lastUpdated")
    }
    
    @objc override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        print("Did become active")
        wantToShowOnlyFavorites()
        getFavorites()
        setTheme()
        self.tableView.reloadData()
    }
    
    @objc func applicationDidBecomeActive() {
        // handle event
        print("Table of Currencies became active again! Update the prices!")
        wantToShowOnlyFavorites()
        cryptoController.updatePrice()
    }
    
    @objc func refreshPull() {
        print("Pulling to refresh - updating!")
        cryptoController.updatePrice()
        refreshControl.endRefreshing()
        checkNetworkReachability()
        setLastUpdateTime()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh - Last updated: " + getLastUpdateTime(), attributes: [NSForegroundColorAttributeName: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)])
    }
    
    
    
    
    // Function to decide whether or not to show favorites only
    func wantToShowOnlyFavorites(){
        
        // Find information about wanting to only show favorite
        if let favoritesOnly = self.defaults.object(forKey: "wantToShowOnlyFavorites") {
            wantToOnlyShowFavoriteCurrencies = favoritesOnly as! Bool
        }else{
            wantToOnlyShowFavoriteCurrencies = false
        }
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // Need to check if personalFavorites really has any favorites
        
        if isFiltering() {
            return 1
        }
        
        if personalFavorites.count == 0 || wantToOnlyShowFavoriteCurrencies{
            return 1
        }else{
            return 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        var headerName = ""
        
        if wantToOnlyShowFavoriteCurrencies{
            headerName = "Favorites"
            return nil
        }
        
        if personalFavorites.count == 0 {
            headerName = "Altcoins"
            return nil
        }
        
        if section == 0 {
            headerName = "Favorites"
        }
        if section == 1 {
            headerName = "Altcoins"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            return filteredCryptos.count
        }
        
        //return cryptos.count
        var rowCount = 0
        
        // If only favorites, show only them
        if wantToOnlyShowFavoriteCurrencies{
            rowCount = personalFavorites.count
            return rowCount
        }
        
        // If no favorites, only show Altcoins
        if personalFavorites.count == 0 {
            rowCount = cryptos.count
            return rowCount
        }
        
        
        if section == 0 {
            rowCount = personalFavorites.count
        }
        if section == 1 {
            rowCount = cryptos.count - personalFavorites.count
        }
        return rowCount
    }
    
    func redrawView() -> Void {
        self.tableView.reloadData()
    }
    
    func reloadCurrencyList() -> Void {
        cryptoController.loadCurrencies()
        cryptos = cryptoController.getCurrencies()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = CryptocurrencyTableViewCell(style: .value1, reuseIdentifier: textCellIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! CryptocurrencyTableViewCell
        
        if defaults.bool(forKey: "blackTheme" ){
            cell.backgroundColor = UIColor.clear
            cell.nameLabel.textColor = UIColor.white
            cell.priceLabel.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
            
            // Change the selected color of the cell when selected
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.2696416974, green: 0.2744067311, blue: 0.27892676, alpha: 1)
            cell.selectedBackgroundView = backgroundView
        }else{
            cell.nameLabel.textColor = UIColor.black
            cell.priceLabel.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.selectedBackgroundView = backgroundView
        }
        
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        //var localCurrency = ""
        var localCurrencySymbol = ""
        if let currency = self.defaults.object(forKey: "selectedCurrency") {
            if let currencySymbol = self.defaults.object(forKey: "selectedCurrencySymbol") {
                // selectedCurrencySymbol
                localCurrency = (currency as? String)!
                localCurrencySymbol = currencySymbol as! String
            }
        }else{
//            print("No currency selected - something went wrong")
            // DEFAULT TO USD!
            localCurrency = "USD"
            localCurrencySymbol = "$"
        }
        
        
        
        // Check if user wants abbreviation or coin name (FULL)
        var wantsCoinAbbreviation:Bool = false
        
        if let userChoice = self.defaults.object(forKey: "wantToShowCoinAbbreviation") {
            wantsCoinAbbreviation = (userChoice as? Bool)!
        }else{
//            print("No coin preference set - something went wrong")
            // DEFAULT TO full coin name
            wantsCoinAbbreviation = false
        }
        
        
        
        let section = indexPath.section
        let row = indexPath.row
        
        var hasFavs = 1
        
        var nameCoin = ""
        var detailCoin = ""
        var imageName = ""
        var change = ""
        
        if !isFiltering() {
        // If section 0 show favorites, but not while filtering
            if personalFavorites.count != 0 {
                if section == 0 {
                    if let i = cryptos.index(where: { $0.baseAbbriviation == personalFavorites[row] }) {
    //                    print("Index: \(i)")
                        cell.baseAbbreviation = cryptos[i].baseAbbriviation
                        change = getTwoDecimals(string: String(describing: cryptos[i].changeLast24h))
                        if (wantsCoinAbbreviation){
                            nameCoin = cryptos[i].baseAbbriviation
                        }else{
                            nameCoin = cryptos[i].baseCurrency
                        }
    //                    print(cryptos[i].baseAbbriviation)
                        //nameCoin = cryptos[i].baseCurrency
                        detailCoin = cryptos[i].getThePrice(currency: localCurrency)
                        imageName = cryptos[i].baseAbbriviation
                    }
                }
            }else{
                hasFavs = 0
            }
        }else{
            hasFavs = 0
        }
        
        var crypto:Cryptocurrency!
        if isFiltering() {
            print(filteredCryptos)
            print(indexPath)
            crypto = filteredCryptos[indexPath.row]
        } else {
            crypto = cryptos[indexPath.row]
        }
        
        
        // If section 1 show all other altcoins
        if !wantToOnlyShowFavoriteCurrencies{
            if section == hasFavs {
                cell.baseAbbreviation = cryptos[row].baseAbbriviation
                change = getTwoDecimals(string: String(describing: cryptos[row].changeLast24h))
                if (wantsCoinAbbreviation){
                    nameCoin = crypto.baseAbbriviation
                }else{
                    nameCoin = crypto.baseCurrency
                }
                
                detailCoin = crypto.getThePrice(currency: localCurrency)
                imageName = crypto.baseAbbriviation
                
               
            }
        }
        
        
        //print(indexPath)
        //cell.textLabel?.text = data[ip.row].baseCurrency
        cell.nameLabel?.text = nameCoin
        
        // DetailLabel
        var pris = detailCoin
        
        // Checking what info is available on pris
        if pris == "Updating..." {
            cell.priceLabel?.text = pris
        }else{
            pris = getTwoDecimals(string: pris)
            if let thePrice = Double(pris){
                cell.priceLabel?.text = formatter.string(from: thePrice as NSNumber)!  + localCurrencySymbol
            }
        }
        change = getTwoDecimals(string: change)
        if let thechange = Double(change){
            cell.changeLabel.text = formatter.string(from: thechange as NSNumber)! + "%"
        }
        
        
        setColorOn24hChange(change: change, cell: cell)
        
        // Add image to cell view
        
        if let image = UIImage(named: imageName){
            cell.cryptoImage?.image = image
        }else{
            if defaults.bool(forKey: "blackTheme" ){
                cell.cryptoImage?.image = UIImage(named: "DCLW.png")
                print("Will use this image")
            }else{
                cell.cryptoImage?.image = UIImage(named: "DCL.png")
                
            }
        }
        
        //cell.imageView?.image = image
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // If we are in the favorite section do nothing
        if indexPath.section == 0{
            return 44.0
        }
        
        // If not, we want to hide the cell from showing
        // Find the placement of the crypto in the cryptos list
        var coin = cryptos[indexPath.row]
        
        // Check if that exsists in the favoritecryptos list
//        print(coin.baseAbbriviation)
        
        
        
        // Check if the coin is a personal favorite
        if let base = coin.baseAbbriviation as? String{
            if personalFavorites.contains(coin.baseAbbriviation){
                return 0
            }
        }
        
        
        
        return 44.0
    }
    
    func setColorOn24hChange(change:String, cell:CryptocurrencyTableViewCell) -> Void {
        var changeInt = Double(change)
        //print(changeInt)
        // Set color based on positive or negative
        if (changeInt! > 0){
            // Positive change
            cell.changeLabel.textColor = UIColor(red: 0, green: 0.733, blue: 0.153, alpha: 1)
            
        }else{
            // Negative change
            cell.changeLabel.textColor = UIColor(red: 0.996, green: 0.125, blue: 0.125, alpha: 1)
            
        }
    }
    
    // MARK:  UITableViewDelegate Methods
//    func tableView(_ tableView: UITableView, didSelectRowAt
//        indexPath: IndexPath){
//        
//        // No need to programatically create this function since it works through the Storyboard.
////        if isFiltering(){
////            print(indexPath)
////        }
//    }
    
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
//        searchText.lowercased()
//        filteredCryptos = cryptos.filter({( crypto : Cryptocurrency) -> Bool in
//            return crypto.baseAbbriviation.lowercased().contains(searchText.lowercased())
//        })
//
//        filteredCryptos = cryptos.filter({( crypto : Cryptocurrency) -> Bool in
//            return crypto.baseCurrency.lowercased().contains(searchText.lowercased())
//        })

        // Filtering on both abbreviation and fullname
        filteredCryptos = cryptos.filter({$0.baseCurrency.lowercased().contains(searchText.lowercased()) || $0.baseAbbriviation.lowercased().contains(searchText.lowercased())})
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        
        return searchController.isActive && !searchBarIsEmpty()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCurrencyInfo"{
//            print("Stemmer")
            
            if let indexPath = tableView.indexPathForSelectedRow{
                let selectedRow = indexPath.row
            
            
                var touchedRow = sender as? CryptocurrencyTableViewCell
    //            print(touchedRow?.baseAbbreviation)
                var theSender:Cryptocurrency!
                if isFiltering() {
                    theSender = filteredCryptos[selectedRow]
    //                candy = filteredCandies[indexPath.row]
                } else {
                    theSender = cryptos[cryptos.index(where: { $0.baseAbbriviation == touchedRow?.baseAbbreviation! })!]
                }
                
                let yourNextViewController = (segue.destination as! DetailCryptoViewController)
                
                yourNextViewController.coin = (theSender.baseAbbriviation)
                yourNextViewController.favoriteCurrency = localCurrency
                let backItem = UIBarButtonItem()
                backItem.title = "Cryptos"
                navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
                yourNextViewController.title = theSender.baseCurrency
                
            }else{
                var touchedRow = sender as? CryptocurrencyTableViewCell
                //            print(touchedRow?.baseAbbreviation)
                var theSender:Cryptocurrency!
//                if isFiltering() {
//                    theSender = filteredCryptos[selectedRow]
//                    //                candy = filteredCandies[indexPath.row]
//                } else {
//                    theSender = cryptos[cryptos.index(where: { $0.baseAbbriviation == touchedRow?.baseAbbreviation! })!]
//                }
                
                theSender = cryptos[cryptos.index(where: { $0.baseAbbriviation == touchedRow?.baseAbbreviation! })!]
                let yourNextViewController = (segue.destination as! DetailCryptoViewController)
                
                yourNextViewController.coin = (theSender.baseAbbriviation)
                yourNextViewController.favoriteCurrency = localCurrency
                let backItem = UIBarButtonItem()
                backItem.title = "Cryptos"
                navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
                yourNextViewController.title = theSender.baseCurrency
            }
        }

    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!, traitCollection: UITraitCollection!) -> UIModalPresentationStyle {
        print("HELLO")
        return UIModalPresentationStyle.none
    }
    
    
    func getFavorites() -> Void {
        if let favoriteCoins = defaults.object(forKey: "favoriteCoins") {
            
            personalFavorites = favoriteCoins as! [String]
//            print("Favorites: ", personalFavorites)
            //userVersion = currentVersion as! Int
        }else{
            print("Something went wrong, no favorites is present.")
            personalFavorites = []
            //userVersion = -1
        }
    }
    
    func getTwoDecimals(string:String) -> String {
        if let intermediate = Double(string){
            let number = String(format: "%.2f", intermediate)
            return number
        }else{
            return string
        }
    }
    
    // MARK: Button actions
    var lastButtonPressed:UIBarButtonItem!
    var isTop:Bool!
    @IBAction func change24HButtonAction(_ sender: Any) {
        sortTableViewChange(isSortedOnTop: isTop)
    }
    @IBAction func coinButtonAction(_ sender: Any) {
        sortTableViewCoin(isSortedOnTop: isTop)
    }
    @IBAction func priceButtonAction(_ sender: Any) {
        sortTableViewPrice(isSortedOnTop: isTop)
    }
    
    func sortTableViewCoin(isSortedOnTop:Bool){
        if isSortedOnTop{
            cryptos.sort { $0.baseCurrency < $1.baseCurrency }
            //personalFavorites.sort {$0 < $1}
            /*
             PRINT ALL CURRENCIES IN ALPHABETICAL ORDER TO ADD THEM TO APP STORE TEXT IF UPDATED AND ADDED MORE CURRENCIES.
            for currency in cryptos{
                // Printing all currencies for App Store text
                print(currency.baseCurrency + " (" + currency.baseAbbriviation + ")" + ",", terminator: " ")
            }
             */
            isTop = false
        }else{
            cryptos.sort { $0.baseCurrency > $1.baseCurrency }
            //personalFavorites.sort {$0 > $1}
            isTop = true
        }
        redrawView()
    }
    
    func sortTableViewPrice(isSortedOnTop:Bool){
        if !isSortedOnTop{
            cryptos.sort { Double($0.getThePrice(currency: localCurrency))! < Double($1.getThePrice(currency: localCurrency))! }
            isTop = true
        }else{
            cryptos.sort { Double($0.getThePrice(currency: localCurrency))! > Double($1.getThePrice(currency: localCurrency))! }
            isTop = false
        }
        redrawView()
    }
    
    func sortTableViewChange(isSortedOnTop:Bool){
        if !isSortedOnTop{
            cryptos.sort { $0.changeLast24h < $1.changeLast24h }
            isTop = true
        }else{
            cryptos.sort { $0.changeLast24h > $1.changeLast24h }
            isTop = false
        }
        redrawView()
    }
    
    // MARK: Check for internet connection
    
    func checkNetworkReachability(){
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "No internet connection", message: "Something went wrong when connecting to the Internet. Please check your connection.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}


extension TableOfCryptocurrencies: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
