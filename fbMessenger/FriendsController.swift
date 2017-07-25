//
//  ViewController.swift
//  fbMessenger
//
//  Created by Michael Lema on 7/13/17.
//  Copyright © 2017 Michael Lema. All rights reserved.
//

import UIKit
import CoreData

class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    private let cellId = "cellId"
    
    //var messages: [Message]?
    
    
    lazy var fetchedResultsController: NSFetchedResultsController<Friend> = {
        //: fetches the Friend entity from CoreData
        let fetchRequest = NSFetchRequest<Friend>(entityName: "Friend")
        
        //: "An instance of NSFetchedResultsController requires a fetch request with sort descriptors"
        //: The sortDescriptor is sorting the Friend object by the last message's date and does not sort in ascending order
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date", ascending: false)]
        
        //: Delete/eliminate an empty row if the user has not had a conversation with a friend
        fetchRequest.predicate = NSPredicate(format: "lastMessage != nil")
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            
            //: When we are performing updates, we can use all of the operations in blockOperations
            //: This loop will run the inserations that are added in the blockOperations.
            for operation in self.blockOperations {
                operation.start()
            }
            

        }, completion: { (completed) in
            
            let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
            let indexPath = IndexPath(item: lastItem, section: 0)
            
            //: Scroll to the new message that is being entered
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            
        
        })
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        //: Bring back the TabBar when the user goes back to the chat lists
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //: Title of the navigation bar
        navigationItem.title = "Recent"
        
        collectionView?.backgroundColor = UIColor.white
        
        //: To bounce the view up and down when a user slides his finger on the collection view
        collectionView?.alwaysBounceVertical = true
        
        
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        
        setUpData()
        
        
        do {
            //: fetchedResultsController contains all the friend items in the database.
            try fetchedResultsController.performFetch()
        } catch let err {
            print(err)
        }
        
        //: Simulate a new friend with a new message
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Friends", style: .plain, target: self, action: #selector(addFriends))
     
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //: Once the user sends a message and goes back to the friend's list, update the collection view to show latest message.
        collectionView?.reloadData()

    }
    
    func addFriends() {
        
        navigationItem.setRightBarButton(nil, animated: true)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        
        //: We must downcast the NSManagedObject as a Friend
        let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        mark.name = "Mark Zuckerberg"
        mark.profileImageName = "zuckprofile"
        
        FriendsController.createMessageWithText(text:  "Hello there, please join my company", friend: mark, minutesAgo: 0, context: context)
        
        
        //: Lets add another Friend with a message to the collectionView
        let bill = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        bill.name = "Bill Gates"
        bill.profileImageName = "billProfile"
        
        FriendsController.createMessageWithText(text: "Come join Microsoft", friend: bill, minutesAgo: 0, context: context)
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        
        //: If there are no objects in the messages array, return 0
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // return collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let friend = fetchedResultsController.object(at: indexPath)
        
        //: Friend object has been updated to contain a new property called lastMessage
        cell.message = friend.lastMessage
        
        return cell
    }
    
    
    
    //: Conforms to the UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    //: When the user taps on a cell, a new UICollectionViewController will appear for the messages
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //: A CollectionViewController needs a collectionViewLayout with layout being a UICollectionViewFlowLayout()
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogControlller(collectionViewLayout: layout)
        
        let friend = fetchedResultsController.object(at: indexPath)
        
        
        //: The row of the friend the user clicks on
        controller.friend = friend
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
}
//: For each of the cell's in the UICollectionView
class MessageCell: BaseCell {
    
    
    override var isHighlighted: Bool {
        didSet {
            
            //: isHighlighted will be set to true when user taps a cell and will be false when user releases tap
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            messageLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            timeLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            
        }
    }
    
    
    var message: Message? {
        
        didSet {
            nameLabel.text = message?.friend?.name
            
            if let profileImageName = message?.friend?.profileImageName {
                profileImageView.image = UIImage(named: profileImageName)
                hasReadImageView.image = UIImage(named: profileImageName)
                
                
            }
            
            messageLabel.text = message?.text
            
            
            //: Modify time label
            if let date = message?.date {
                
                let dateFormatter = DateFormatter()
                //: h, represents the hour, mm represents the minutes, and a is the am or pm
                dateFormatter.dateFormat = "h:mm a"
                
                
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
                
                //: 86,400 seconds in a day
                let secondsInOneday: TimeInterval = 60 * 60 * 24
                
                
                //: If the elapsedTimeInSeconds is greater than a week, change the dateFormat
                if elapsedTimeInSeconds > 7 * secondsInOneday {
                    
                    dateFormatter.dateFormat = "MM/dd/yy"
                    
                    //: If the elapsedTimeInSeconds is greater than one day, change the dateFormat
                } else if elapsedTimeInSeconds > secondsInOneday {
                    
                    //: "EEE" specifies a 3 letter day abbreviation of day name, Wednesday ->  Wed
                    dateFormatter.dateFormat = "EEE"
                }
                
                //: Update the cell timeLabel with the current date
                timeLabel.text = dateFormatter.string(from: date as Date)
            }
            
        }
    }
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        //: Make the image into a circle
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
        
    }()
    
    
    let dividerLineView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
        
    }()
    
    
    let nameLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Friend's Name"
        return label
        
    }()
    
    let messageLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "My exclusive message and other details go here..."
        return label
        
    }()
    
    let timeLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        label.text = "11:11 pm"
        return label
    }()
    
    let hasReadImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        //: Make the image into a circle
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
        
    }()
    
    
    override func setUpViews() {
        
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        //: The following creates a containter to hold the name and message label
        setUpContainerView()
        
        //: Adding image to profileView and hasReadImageView
        profileImageView.image = UIImage(named: "zuckprofile")
        hasReadImageView.image = UIImage(named: "zuckprofile")
        
        //: 1) MARK: Set the constraints to actually use them
        
        /*
         //: This was replaced with the new extension file created in ConstrantsExtension.swift
         profileImageView.translatesAutoresizingMaskIntoConstraints = false
         dividerLineView.translatesAutoresizingMaskIntoConstraints = false
         */
        
        // 2) MARK: Setting the constraints for the imageView
        /*
         addConstraints(NSLayoutConstraint.constraints(
         //: Horizontal Width of 68
         withVisualFormat: "H:|-12-[v0(68)]",
         options: NSLayoutFormatOptions(),
         metrics: nil,
         views: ["v0" : profileImageView]))
         
         addConstraints(NSLayoutConstraint.constraints(
         //: Vertical height of 68
         withVisualFormat: "V:|-12-[v0(68)]",
         options: NSLayoutFormatOptions(),
         metrics: nil,
         views: ["v0" : profileImageView]))
         */
        
        addConstraintsWithFormat(format: "H:|-12-[v0(68)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(68)]", views: profileImageView)
        
        //: The folllowing puts the profileImageView in the center of the cell, depending on the size of the cell
        addConstraint(NSLayoutConstraint.init(
            item: profileImageView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        
        
        // 3) MARK: Setting the constraints for the dividerLine
        
        /*
         //: This was replaced with the new extension file created in ConstrantsExtension.swift
         addConstraints(NSLayoutConstraint.constraints(
         withVisualFormat: "H:|-82-[v0]|",
         options: NSLayoutFormatOptions(),
         metrics: nil,
         views: ["v0" : dividerLineView]))
         
         addConstraints(NSLayoutConstraint.constraints(
         withVisualFormat: "V:[v0(1)]|",
         options: NSLayoutFormatOptions(),
         metrics: nil,
         views: ["v0" : dividerLineView]))
         */
        addConstraintsWithFormat(format: "H:|-82-[v0]|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: dividerLineView)
        
        
    }
    
    private func setUpContainerView() {
        
        let containerView = UIView()
        addSubview(containerView)
        
        //: Set constraints for the containerView
        addConstraintsWithFormat(format: "H:|-90-[v0]|", views: containerView)
        addConstraintsWithFormat(format: "V:[v0(50)]", views: containerView)
        
        //: Set constraints for the containerView to be in the center of the cell
        addConstraint(NSLayoutConstraint.init(
            item: containerView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        //: Place the name, message, and time label and hasReadImage inside the container view
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        //: Set the constraints for the name, message, and time Label and hasReadImage inside the container view
        addConstraintsWithFormat(format: "H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        addConstraintsWithFormat(format: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
        addConstraintsWithFormat(format: "V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        addConstraintsWithFormat(format: "V:|[v0(24)]", views: timeLabel)
        addConstraintsWithFormat(format: "V:[v0(20)]|", views: hasReadImageView)
        
        
    }
    
}

class BaseCell: UICollectionViewCell {
    
    //: The setUpViews() is called in init(frame) which is called whenever the cell is dequeued
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
    }
}

