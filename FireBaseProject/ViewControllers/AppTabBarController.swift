//
//  TabBarController.swift
//  FireBaseProject
//
//  Created by Kevin Natera on 11/26/19.
//  Copyright © 2019 Kevin Natera. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let feedVC = storyBoard.instantiateViewController(identifier: "feedVC") as! FeedVC
       
       
        let secondVC = UploadVC(), thirdVC  = ProfileVC()
        feedVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "text.bubble"), tag: 0)
        secondVC.tabBarItem = UITabBarItem(title: "Upload", image: UIImage(systemName: "photo"), tag: 1)
        thirdVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 2)
        self.setViewControllers([feedVC,secondVC,thirdVC], animated: false)
    }
    
}
