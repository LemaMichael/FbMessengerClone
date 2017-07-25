//
//  ChatLogController.swift
//  fbMessenger
//
//  Created by Michael Lema on 7/18/17.
//  Copyright © 2017 Michael Lema. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ChatLogControlller: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    private let cellId = "cellId"
    
    var friend: Friend? {
        
        didSet {
            navigationItem.title = friend?.name
            
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
        
        FriendsController.createMessageWithText(text: inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        
        do {
            try context.save()
            
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
        FriendsController.createMessageWithText(text: "This text message was delayed, sorry", friend: friend!, minutesAgo: 1, context: context)
        FriendsController.createMessageWithText(text: "I had no signal", friend: friend!, minutesAgo: 1, context: context)

        
        do {
            try context.save()
            
        } catch let err {
            print(err)
        }
        
    }
    
    
    //: The bottomConstraint for the messageInputContanerView will be updated if the keyboard shows up
    var bottomConstraint: NSLayoutConstraint?
    
    
    //: Set as a lazy var because member 'friend' cannot be used on type ChatLogController, I need access to friend.name
    lazy var fetchedResultController: NSFetchedResultsController<Message> = {
       
        let fetchRequest = NSFetchRequest<Message>(entityName: "Message")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        //: "An instance of NSFetchedResultsController requires a fetch request with sort descriptors"
        //: The sortDescriptor is sorting the Message object by date and sorts in ascending order
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        fetchRequest.predicate = NSPredicate(format: "friend.name = %@", self.friend!.name!)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
        
    }()
    
    var blockOperations = [BlockOperation]()
    
    //: This delegate method, which is part of NSFetchedResultsControllerDelegate, is called every time a new object is inserted to Core Data.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        if type == .insert {
            blockOperations.append(BlockOperation(block: {
                
                self.collectionView?.insertItems(at: [newIndexPath!])

            }))
        }
    }
    
    
    //:
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({ 
            //: When we are performing updates, we can use all of the operations in blockOperations
            //: This loop will run the inserations that are added in the blockOperations.
            for operation in self.blockOperations {
                
                operation.start()
            }
            
        }, completion: { (completed) in
            
            let lastItem = self.fetchedResultController.sections![0].numberOfObjects - 1
            let indexPath = IndexPath(item: lastItem, section: 0)
            
            //: Scroll to the new message that is being entered
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultController.performFetch()
            //: Print number of messages
            //print(fetchedResultController.sections![0].numberOfObjects)
            
        } catch let err {
            print(err)
        }
        
        
        
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
                    
                    let lastItem = self.fetchedResultController.sections![0].numberOfObjects - 1
                    let indexPath = IndexPath(item: lastItem, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
         
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
        
        //: Will now use fetchResultController to determine the numberOfItemsInSection
        if let count = fetchedResultController.sections?[0].numberOfObjects {
            return count
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        
        //: Get the message from fetchedResultController
        let message = fetchedResultController.object(at: indexPath)
        
        //: Set the cell's messageTextView with the correct message (text) from message
        cell.messageTextView.text = message.text
        
        //: Safe unwrapping the message text and profile image
        if let messageText = message.text, let profileImageName = message.friend?.profileImageName {
            
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
        
        let message = fetchedResultController.object(at: indexPath)
        
        //: Safe unwrapping of the actual text inside the fetchResultController Message object
        if let messageText = message.text {
            
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
