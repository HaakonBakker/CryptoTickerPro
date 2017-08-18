//
//  PortfolioController.swift
//  BitcoinTicker
//
//  Created by Haakon W Hoel Bakker on 03/08/2017.
//  Copyright © 2017 Haakon W Hoel Bakker. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PortfolioController {
    var portfolios:[Portfolio]?
    
    var portArr:[Port]?
    let appDelegate:AppDelegate
    let context:NSManagedObjectContext
    
    //var portfolioCalculations:PortfolioCalculations!
    
    var ports = [Port]()
    static let sharedInstance = PortfolioController()
    
    private init() {
        // Set up core data 
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext

        
        let willNeedDeletion = false
        if willNeedDeletion {
            // Delete all old records:
            self.deleteAllRecords()
            addTestObjects()
        }

        // Load portfolios
        loadPortfolios()
        print(fetchPortfolios())
        print("Loaded portfolio")
        print("COUNT OF PORTFOLIOS:")
        print(portArr?.count)
        
        
    }
    
    func fetchPortfolios() -> [Port]{
        do {
            ports = try context.fetch(Port.fetchRequest())
        }catch {
            print("Error fetching data from CoreData")
        }
        print("Count of fetched portfolios: \(ports.count)")
        
        ports.sort {
            $0.name! < $1.name!
        }
        
        return ports
    }
    
    
    func getTotalPortfoliosCost() -> Double {
        var cost = 0.0
        print(portArr)
        // Need to fix this. Is not unwrapped
        for port in ports {
            cost = cost + port.cost
            print(cost)
        }
        
        
        return cost
    }
    
    func getPortfolioValue() -> Double{
        var totalValue = 0.0

        for port in ports {
            var portfolioCalc = PortfolioCalculations(port:port)
            print(port.name)
            print(portfolioCalc.calculateCurrentValue())
            totalValue = totalValue + portfolioCalc.calculateCurrentValue()
        }
        // Will return current value in [Double][0] and cost in [Double][1]
        
        return totalValue
    }
    
    func getPortfoliosCost(rate: @escaping (Double) -> ()){
        
        var counter = 0
        var totalCost = 0.0
        var totalPorts = ports.count
        for port in ports {
            var portfolioCalc = PortfolioCalculations(port:port)
            portfolioCalc.calculateCost(rate: { (success) -> Void in
                
                totalCost = totalCost + (port.cost * success)
                counter = counter + 1
                if totalPorts == counter {
                    rate(totalCost)
                }
                
            })
        }
        //return totalCost
    }
    
    func updateStatus(){
        fetchPortfolios()
    }
    
    // Load portfolio
    func loadPortfolios(){
        // Need to load all the elements for each portfolio
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Port")
        
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                /*
                for result in results as! [NSManagedObject]{
                    // Convert to portfolio
                    let currency = Cryptocurrency()
                    if let name = result.value(forKey: "name") as? String {
                        //print(name)
                        currency.baseCurrency = name
                    }
                    if let abbr = result.value(forKey: "cost") as? String {
                        currency.baseAbbriviation = abbr
                    }
                    if let price = result.value(forKey: "costCurrency") as? Double {
                        currency.target = price
                    }
                    
                    
                    //let element = result.elementRelationship as Element
                    // Add to the portfolio array
                }
                
                */
                
                for portfolio in results as! [Port] {
                    //let person = book.elementRelationship as El
                    let elArr = portfolio.elementRelationship
                    let myArr = Array(elArr!)
                    print("PRINTING THE ELEMENTS OF THE FOLLOWING PORTFOLIO:")
                    print(portfolio.name)
                    for a in myArr as! [El]{
                        print(a.currency)
                        print(a.amount)
                    }
                    portArr?.append(portfolio)
                    
                    //println(person.namePerson)
                    //println(person.idPerson)
                }
            }
        }catch{
            // Do some error handling here.
        }
    }
    
    // Save portfolio
    
    
    // Create test objects
    func addTestObjects(){
        // Add a Portfolio
        
        // Add one Portfolio
        let obj = NSEntityDescription.insertNewObject(forEntityName: "Port", into: context) as! Port
        obj.name = "My BTC Portfolio"
        obj.cost = 200
        obj.costCurrency = "NOK"
        
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        // Add Two elements to it
        let el1 = NSEntityDescription.insertNewObject(forEntityName: "El", into: context) as! El
        el1.amount = 240
        el1.currency = "BTC"
        el1.relationship = obj
        
        let el2 = NSEntityDescription.insertNewObject(forEntityName: "El", into: context) as! El
        el2.amount = 430
        el2.currency = "ETH"
        el2.relationship = obj
        
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        // Add another portfolio
        
        let obj2 = NSEntityDescription.insertNewObject(forEntityName: "Port", into: context) as! Port
        obj2.name = "ETH Portfolio"
        obj2.cost = 30
        obj2.costCurrency = "USD"
        
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        // Add Two elements to it
        let el3 = NSEntityDescription.insertNewObject(forEntityName: "El", into: context) as! El
        el3.amount = 10
        el3.currency = "ETH"
        el3.relationship = obj2
        
        let el4 = NSEntityDescription.insertNewObject(forEntityName: "El", into: context) as! El
        el4.amount = 30
        el4.currency = "ETC"
        el4.relationship = obj2
        
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Port")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func deletePortfolio(port:Port){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Port")
        
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                context.delete(port)
            }
        }
    }
    
    func deleteAsset(asset:El){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "El")
        
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                context.delete(asset)
            }
        }
    }
    
    // MARK: - Accessors
    
    class func shared() -> PortfolioController {
        return sharedInstance
    }
}
