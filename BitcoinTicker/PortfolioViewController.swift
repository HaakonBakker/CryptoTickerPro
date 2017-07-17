//
//  PortfolioViewController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 17/07/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class PortfolioViewController: UIViewController {
    var portfolio:Portfolio?
    override func viewDidLoad() {
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        print("Portfolioview has been loaded")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPortfolio"{
            print("StemmertilEditPortfolio")
            let editViewController = (segue.destination as! PortfolioEditViewController)
            editViewController.portfolio = portfolio
            
        }
    }
}
