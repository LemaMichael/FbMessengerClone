//
//  ChatLogController.swift
//  fbMessenger
//
//  Created by Michael Lema on 7/18/17.
//  Copyright © 2017 Michael Lema. All rights reserved.
//

import Foundation
import UIKit

class ChatLogControlller: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    
    var messages: [Message]?
    
    var friend: Friend? {
        
        didSet {
            navigationItem.title = friend?.name
            
            //: friends?.messages is an NSSet so we use allObjects to then down cast it as an array of type Message
            messages = friend?.messages?.allObjects as? [Message]
            
            
            /* 
             -Sort the messages by its date.
             -(Without this the messages in the ChatLogController will not be in order 
              because the fetch order of the friend?.messages?.allObjects is not in any particular order)
            */
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})

        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        
        //: We must register the cell class
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
    
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        //: Set the cell's messageTextView with the correct message (text) inside the messages array
        cell.messageTextView.text = messages?[indexPath.item].text
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
}

class ChatLogMessageCell: BaseCell {
    
    
    let messageTextView: UITextView = {
       let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Sample message"
        return textView
        
    }()
    
    override func setUpViews() {
        super.setUpViews()
        
        //: add messageTextView onto the hierarchy of the cell
        addSubview(messageTextView)
        
        //: Constraints for the messageTextView inside the cell
        addConstraintsWithFormat(format: "H:|[v0]|", views: messageTextView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: messageTextView)
        
    }
    
    
}
