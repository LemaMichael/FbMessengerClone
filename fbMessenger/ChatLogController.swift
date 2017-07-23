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
        
        //: Hide tabBar when messages list appears
        tabBarController?.tabBar.isHidden = true
        
        
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
        
        //: Safe unwrapping the message text and profile image
        if let message = messages?[indexPath.item], let messageText = message.text, let profileImageName = message.friend?.profileImageName {
            
            //: Display the cell's profile image
            cell.profileImageView.image = UIImage(named: profileImageName)
            
            
            //: Changing the width of each cell to 250
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            
            //: Message is from another user
            if !message.isSender {
                
                //: Added 8 pixels in the x position to give the messageTextView more left spacing and 40 more pixels to show the profile image
                cell.messageTextView.frame = CGRect(x: 8 + 48, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                
                //: The following line sets the cell's textBubbleView frame, also added 8 pixels to the width since the messageTextView's x position has changed.
                cell.textBubbleView.frame = CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
                
                cell.profileImageView.isHidden = false
                
                //: It is important to have these three lines for both outgoing and incoming messages because when the cells get recycled, it resets all its following properties.
                cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.messageTextView.textColor = UIColor.black
                
            } else {
                
                //: Message is from the user
                
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                
                cell.profileImageView.isHidden = true
                
                //: Because the message is from the user, I want the chat bubble to be a blue color
                cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
                
            }
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
    
    
    //: Without this method, the first cell will start at the top of the navigation bar's bottom
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //: This will give 8 pixels for each section (we only have 1 section)
        return UIEdgeInsetsMake(8, 0, 0, 0)
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
        //view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        //: Make the bubbleView rounded
        view.layer.cornerRadius = 15
        //: To get the cornerRadius to show, do the following line
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    static let blueBubbleImage = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        
        // withRenderingMode(.alwaysTemplate) draws the image as a template image, ignoring its color information
        imageView.image = ChatLogMessageCell.grayBubbleImage
        
        //: Now that the image is rendered as a template image, the tint color can be modified
        imageView.tintColor = UIColor(white: 0.95, alpha: 1)
        return imageView
    }()
    
    
    override func setUpViews() {
        super.setUpViews()
        
        
        //: add the textBubbleView onto the hierarchy of the cell
        addSubview(textBubbleView)
        
        //: add messageTextView onto the hierarchy of the cell
        addSubview(messageTextView)
        
        addSubview(profileImageView)
        //: Constraints for the profileImageView inside the cell
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: profileImageView)
        profileImageView.backgroundColor = UIColor.red
        
        
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstraintsWithFormat(format: "H:|[v0]|", views: bubbleImageView)
        textBubbleView.addConstraintsWithFormat(format: "V:|[v0]|", views: bubbleImageView)
        
        
        //: Constraints for the messageTextView inside the cell
        /* Needed to remove both constraints to let collectionView(_collectionView:cellForItemAt) modify the cell width and height
         addConstraintsWithFormat(format: "H:|[v0]|", views: messageTextView)
         addConstraintsWithFormat(format: "V:|[v0]|", views: messageTextView)
         */
    }
    
    
}
