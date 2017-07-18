//
//  ViewController.swift
//  fbMessenger
//
//  Created by Michael Lema on 7/13/17.
//  Copyright © 2017 Michael Lema. All rights reserved.
//

import UIKit

class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //: Title of the navigation bar
        navigationItem.title = "Recent"
        
        collectionView?.backgroundColor = UIColor.white
        
        //: To bounce the view up and down when a user slides his finger on the collection view
        collectionView?.alwaysBounceVertical = true
        
        
        collectionView?.register(FriendsCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    }
    
    
    
    //: Conforms to the UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
    
}

class FriendsCell: BaseCell {
    
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        backgroundColor = UIColor.blue
        
    }
}

