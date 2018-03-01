//
//  MainTabBarController.swift
//  instagram_firebase
//
//  Created by Qichen Huang on 2018-02-15.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        setupViewControllers()
        configureTabBar()
    }
    
    public func setupViewControllers() {
    
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let requestNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "request"), selectedImage: #imageLiteral(resourceName: "request_selected"))
        
        let courseNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "course"), selectedImage: #imageLiteral(resourceName: "course_selected"), rootViewController:
            CourseController(collectionViewLayout: UICollectionViewFlowLayout()))
     
        let userProfileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        viewControllers = [homeNavController,
                           requestNavController,
                           courseNavController,
                           userProfileNavController]
    }
    
    private func configureTabBar() {
        tabBar.tintColor = .orange
        tabBar.isTranslucent = false
        tabBar.unselectedItemTintColor = UIColor.black

        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.8)
        topBorder.backgroundColor = UIColor(r: 229, g: 231, b: 235).cgColor
        
        tabBar.clipsToBounds = true
        tabBar.layer.addSublayer(topBorder)//or try addSubview
    }
    
    private func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.title = nil
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        return navController
    }
    
}