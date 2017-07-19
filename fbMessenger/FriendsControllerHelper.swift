//
//  FriendsControllerHelper.swift
//  fbMessenger
//
//  Created by Michael Lema on 7/18/17.
//  Copyright © 2017 Michael Lema. All rights reserved.
//

import Foundation
import UIKit
import CoreData


extension FriendsController {
    
    
    
    func setUpData() {
        
        //: Delete all of the objects that were created as duplicates
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        //: In Swift 3, you can access the NSManagedObjectContext via the viewContext of the persistentContainter
        if let context = delegate?.persistentContainer.viewContext {
            
            //: We must downcast the NSManagedObject as a Friend
            let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            mark.name = "Mark Zuckerberg"
            mark.profileImageName = "zuckprofile"
            
            //: We must downcast the NSManagedObject as a Message
            let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            message.friend = mark
            message.text = "Hello there, please join my company"
            message.date = NSDate()
            
            
            let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            steve.name = "Steve Jobs"
            steve.profileImageName = "steve_profile"
            
            let messageSteve = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            messageSteve.friend = steve
            messageSteve.text = "Apple is worth over 750 Billion Dollars and is not stopping anytime soon"
            messageSteve.date = NSDate()
            
            
            
            //: This will save all the core data objects every time the app is launched, creating duplicates... Not good
            do {
                try (context.save())
            } catch let err {
                print(err)
            }
        }
        
        loadData()
    }
    
    
    func clearData() {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            do {
                
                //: Clear the Friend and Message objects from core data
                let entityNames = ["Friend","Message"]
                
                for entityName in entityNames {
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let objects = try(context.fetch(fetchRequest) as? [NSManagedObject])
                    
                    for object in objects! {
                        context.delete(object)
                    }
                }
                
                try (context.save())
                
            } catch let err {
                print(err)
            }
        }
        
    }
    
    
    
    func loadData() {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
            
            do {
                //: Must downcast the NSFetchRequest as an array of Message objects.. this sets up the messages Array.
                
                messages = try (context.fetch(fetchRequest) as? [Message])
            } catch let err {
                print(err)
            }
            
            
        }
        
        
    }
    
    
    
    
    
    
}
