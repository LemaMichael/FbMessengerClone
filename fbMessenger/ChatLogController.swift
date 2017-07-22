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
        
        //: Changing the width of each cell to 250
        if let messageText = messages?[indexPath.item].text {
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            //: Added 8 pixels in the x position to give the messageTextView more left spacing
            cell.messageTextView.frame = CGRect(x: 8, y: 0, width: 250 + 16, height: estimatedFrame.height + 20)
            
            //: The following line sets the cell's textBubbleView frame, also added 8 pixels to the width since the messageTextView's x position has changed.
            cell.textBubbleView.frame = CGRect(x: 0, y: 0, width: 250 + 16 + 8, height: estimatedFrame.height + 20)
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //: Safe unwrapping of the actual text inside each row 
        if let messageText = messages?[indexPath.item].text {
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            //: Now that we have the estimated frame, we can return a CGSize
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
            
        }
        return CGSize(width: view.frame.width, height: 100)
    }
 
    
    
}

class ChatLogMessageCell: BaseCell {
    
    
    let messageTextView: UITextView = {
       let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        return textView
        
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        //: Make the bubbleView rounded
        view.layer.cornerRadius = 15
        //: To get the cornerRadius to show, do the following line
        view.layer.masksToBounds = true
        
        return view
    }()
    
    override func setUpViews() {
        super.setUpViews()
        
        
        //: add the textBubbleView onto the hierarchy of the cell
        addSubview(textBubbleView)
        
        //: add messageTextView onto the hierarchy of the cell
        addSubview(messageTextView)
        
        //: Constraints for the messageTextView inside the cell
        /* Needed to remove both constraints to let collectionView(_collectionView:cellForItemAt) modify the cell width and height
        addConstraintsWithFormat(format: "H:|[v0]|", views: messageTextView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: messageTextView)
        */
    }
    
    
}
