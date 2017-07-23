//
//  Message+CoreDataProperties.swift
//  fbMessenger
//
//  Created by Michael Lema on 7/22/17.
//  Copyright © 2017 Michael Lema. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var isSender: Bool
    @NSManaged public var friend: Friend?

}
