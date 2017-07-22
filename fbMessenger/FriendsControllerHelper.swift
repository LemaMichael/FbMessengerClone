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
            
            
            createMessageWithText(text: "Hey there", friend: steve, minutesAgo: 3, context: context)
            createMessageWithText(text: "Apple is worth over 750 Billion Dollars and is not stopping anytime soon. With the new iPhone being released soon, many investors are choosing Apple as their next stock pick.", friend: steve, minutesAgo: 2, context: context)
            createMessageWithText(text: "Now is the time to invest in Apple! ", friend: steve, minutesAgo: 1,  context: context)
            
            
            let donald = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            donald.name = "Donald Trump"
            donald.profileImageName = "donald_profile"
            
            createMessageWithText(text: "I'm the 45th President of the United States of America", friend: donald, minutesAgo: 5, context: context)
            
            
            let gandi = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            gandi.name = "Mahatma Gandhi"
            gandi.profileImageName = "gandhi_profile"
            createMessageWithText(text: "Hello, nice to meet you...", friend: gandi, minutesAgo: 60 * 24, context: context)
            
            let arnold = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            arnold.name = "Arnold Schwarzenegger"
            arnold.profileImageName = "arnold_profile"
            createMessageWithText(text: "Message me when you're free to workout 💪🏻", friend: arnold, minutesAgo: 8 * 60 * 24 , context: context)
            
            
            
            //: This will save all the core data objects every time the app is launched, creating duplicates... Not good
            //: UPDATE: ClearData() function solves the problem of erasing the duplicates
            do {
                try (context.save())
            } catch let err {
                print(err)
            }
        }
        
        loadData()
    }
    
    
    private func createMessageWithText(text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext) {
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        //: .addingTimeInterval() takes seconds as its arguement
        message.date = NSDate().addingTimeInterval(-minutesAgo * 60)
        
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
        //: loadData is where we fetch out all the entities that are called Message
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            
            
            //: Check if friends is empty
            if let friends = fetchFriends() {
                
                messages = [Message]()
                
                for friend in friends {
                    //: For clarity of each friend's name
                    print(friend.name!)
                    
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                    
                    //: Sort the messages by the date property.
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                    
                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                    fetchRequest.fetchLimit = 1
                    
                    
                    do {
                        //: Must downcast the NSFetchRequest as an array of Message objects.. this will help set up the messages Array.
                        let fetchedMessages = try (context.fetch(fetchRequest) as? [Message])
                        messages?.append(contentsOf: fetchedMessages!)
                        
                        
                    } catch let err {
                        print(err)
                    }
                }
                
                /* MARK: Preserve the order of messages
                    -You use $0 for the first item in the array you're trying to compare
                    -date is a property of Message
                    -We compare the second object by using $1
                */
                messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
                
            }
        }
        
        
    }
    
    
    
    private func fetchFriends() -> [Friend]? {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            
            do {
                return try context.fetch(request) as? [Friend]
            } catch let err {
                print(err)
            }
            
        }
        
        //: If we get here, that means we have a context that is not working
        return nil
        
    }
    
    
    
    
    
    
    
}
