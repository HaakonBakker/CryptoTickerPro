//
//  OnboardingVC.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 09/08/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import UIKit

class OnboardingVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    @IBAction func getStartedButtonAction(_ sender: Any) {
        // Need to set the default to not show the onboarding again.
        let defaults = UserDefaults.standard
        let finishedOnboarding = "Cryptolist"
        UserDefaults.standard.setValue(finishedOnboarding, forKey: "LaunchView")
        
        // Need to change the Storyboard.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
        present(vc, animated: true, completion: nil)
    }
}
