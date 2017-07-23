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
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
        
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Send a message..."
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        //: Add a target to the button
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    
    func handleSend() {
        //: Add the message to core data
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let message = FriendsController.createMessageWithText(text: inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        
        do {
            try context.save()
            
            messages?.append(message)
            let item = messages!.count - 1
            
            let insertionIndexPath = IndexPath(item: item, section: 0)
            collectionView?.insertItems(at: [insertionIndexPath])
            
            //: Move the new message to the top of the keyboard
            collectionView?.scrollToItem(at: insertionIndexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
            
            //: Make the text field empty once the message is sent
            inputTextField.text = nil
            
        } catch let err {
            print(err)
        }
        
    }
    
    func simulate() {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        //: Simulate a message sent minutes ago
        let message = FriendsController.createMessageWithText(text: "This text message was delayed, sorry", friend: friend!, minutesAgo: 1, context: context)
        
        
        do {
            try context.save()
            
            messages?.append(message)
            
            //: We must order the message again by date
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
            
            
            if let item = messages?.index(of: message) {
                let receivingIndexPath = IndexPath(item: item, section: 0)
                collectionView?.insertItems(at: [receivingIndexPath])
            }
            
            } catch let err {
                print(err)
            }
            
        }
        
        
        //: The bottomConstraint for the messageInputContanerView will be updated if the keyboard shows up
        var bottomConstraint: NSLayoutConstraint?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
            
            
            //: Hide tabBar when messages list appears
            tabBarController?.tabBar.isHidden = true
            
            
            collectionView?.backgroundColor = UIColor.white
            
            //: We must register the cell class
            collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
            
            //: Adding the messageInputContainerView to the view
            view.addSubview(messageInputContainerView)
            view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
            view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
            
            
            bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            view.addConstraint(bottomConstraint!)
            
            
            setUpInputComponents()
            
            //: Implement a listener for when the keyboard will show up
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
            
            //: Implement a listener for when the keyboard will dismisses itself
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
            
            
        }
        
        func handleKeyboardNotification(notification: NSNotification) {
            
            if let userInfo = notification.userInfo {
                let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
                
                //: check the NSNotification.Name to see if the keyboard will show
                let isKeyboardShowing = notification.name == .UIKeyboardWillShow
                
                
                //: The bottom constraint will move up when the keyboard displays and move down when it dismisses iteself
                bottomConstraint?.constant =  isKeyboardShowing ? -(keyboardFrame!.height) : 0
                
                
                //: This will help animate the messageInputContainerView when its bottom constraint is updated and the message list to move up
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    
                    // only animate to the last item's bottom in the UICollectionView if the keyboard will show
                    if isKeyboardShowing {
                        let indexPath = IndexPath(item: self.messages!.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
                    }
                })
                
            }
        }
        
        private func setUpInputComponents() {
            
            //: Add a top border to the messageInputContainerView
            let topBorderView = UIView()
            topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
            
            
            //: Adding the inputTextField, sendButton and the topBorderView to the messageInputContainerView
            messageInputContainerView.addSubview(inputTextField)
            messageInputContainerView.addSubview(sendButton)
            messageInputContainerView.addSubview(topBorderView)
            
            //: Constraints for the inputTextField and sendButton
            messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
            messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
            messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
            
            //: Constraints for the topBorderView
            messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
            messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)
            
            
        }
        
        
        override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            inputTextField.endEditing(true)
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
            textView.isEditable = false
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
