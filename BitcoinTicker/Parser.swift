//
//  Parser.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 09/06/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation

/*
 The Parser class will return a Dictionary object that another class can use.
*/



class Parser{
    //var targetURL:String
    
    init() {
        //targetURL = url
    }
    
    func networkRequest(APICall: String, completion: @escaping ([String:Any]) -> ()){
        let urlString = URL(string: APICall)
        //var urlContents: NSString?
        if let url = urlString {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    if let usableData = data {
                        print(usableData[1]) //JSONSerialization
                        
                        
                        do{
                            
                            let jsonResult = try JSONSerialization.jsonObject(with: usableData, options: []) as? [String:Any]
                            
                            
                            completion(jsonResult!)
                            
                            
                            
                            // Testing NSTextField
                            //label.stringValue = info
                            //header.stringValue = headeren
                            
                            // If call and json parsing is successful, then jsonResult is returned.
                            
                        }catch let error as NSError {
                            print(error.localizedDescription)
                            print("This is wrong")
                        }
                        
                        
                    }
                    
                }
            }
            
            task.resume()
            
        }
    }

}
