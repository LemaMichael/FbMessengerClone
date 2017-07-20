//
//  CustomTabBarController.swift
//  fbMessenger
//
//  Created by Michael Lema on 7/19/17.
//  Copyright © 2017 Michael Lema. All rights reserved.
//

import Foundation
import UIKit



class CustomTabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //: setup our custom view controllers
        let layout = UICollectionViewFlowLayout()
        let friendsController = FriendsController(collectionViewLayout: layout)
        let recentMessagesNavController = UINavigationController(rootViewController: friendsController)
        
        //: Set the Tab bar item name and image
        recentMessagesNavController.tabBarItem.title = "Recent"
        recentMessagesNavController.tabBarItem.image = UIImage(named: "recent")
        
        
        
        
        
        
        //: An array of the root view controllers displayed by the tab bar interface.
        viewControllers = [
            recentMessagesNavController,
            createNavControllerWithTitle(title: "Calls", imageName: "calls"),
            createNavControllerWithTitle(title: "Groups", imageName: "groups"),
            createNavControllerWithTitle(title: "People", imageName: "people"),
            createNavControllerWithTitle(title: "Settings", imageName: "settings")
        ]
        
        
    }
    
    
    
    private func createNavControllerWithTitle(title: String, imageName: String) -> UINavigationController {
        
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
        
    }
    
    
    
    
}

