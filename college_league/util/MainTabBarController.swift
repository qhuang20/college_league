//
//  MainTabBarController.swift
//  instagram_firebase
//
//  Created by Qichen Huang on 2018-02-15.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase
import AMScrollingNavbar

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()

        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let introController = IntroController(collectionViewLayout: UICollectionViewFlowLayout())
                let navController = UINavigationController(rootViewController: introController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        setupViewControllers()
    }
    
    public func setupViewControllers() {
    
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let requestNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "request"), selectedImage: #imageLiteral(resourceName: "request_selected"),rootViewController: RequestController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let courseNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "course"), selectedImage: #imageLiteral(resourceName: "course_selected"), rootViewController:
            CourseController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let notificationNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "message"), selectedImage: #imageLiteral(resourceName: "message_selected"), rootViewController: NotificationsController())
        
        let userProfileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        viewControllers = [homeNavController,
                           requestNavController,
                           courseNavController,
                           notificationNavController,
                           userProfileNavController]
        
        selectedIndex = 2
    }
    
    private func configureTabBar() {
        tabBar.tintColor = .orange
        tabBar.unselectedItemTintColor = UIColor.black
        tabBar.isTranslucent = false

        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.8)
        topBorder.backgroundColor = UIColor(r: 229, g: 231, b: 235).cgColor
        
        tabBar.clipsToBounds = true
        tabBar.layer.addSublayer(topBorder)//or try addSubview
    }
    
    private func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> ScrollingNavigationController {
        let navController = ScrollingNavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.title = nil
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        return navController
    }
    
}



