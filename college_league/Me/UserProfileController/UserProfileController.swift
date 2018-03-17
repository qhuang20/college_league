//
//  UserProfileController.swift
//  instagram_firebase
//
//  Created by Qichen Huang on 2018-02-15.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var userId: String?
    
    var user: User?
    var posts = [Post]()
    
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        
        if userId == nil {
            setupLogOutButton()
            setupPostButton()
        }

        fetchUserAndUserPosts()
    }
    
    private func configureCollectionVeiw() {
        collectionView?.backgroundColor = UIColor.white
        collectionView?.showsVerticalScrollIndicator = false
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(UserPostCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    private func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    private func setupPostButton() {
        let button = UIButton(type: .custom)
        let image = #imageLiteral(resourceName: "post").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.adjustsImageWhenHighlighted = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserPostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 50 + 28//userInfo
        let width = view.frame.width
        
        if let imageHeight = posts[indexPath.item].thumbnailImageHeight {
            if imageHeight > 250 { height += 250 }
            else { height += imageHeight }
        }
        
        let postTitleHeight = estimateHeightForPostTitle(text: posts[indexPath.item].title)
        height += postTitleHeight

        return CGSize(width: width, height: height)
    }
    
    private func estimateHeightForPostTitle(text: String) -> CGFloat {
        let attributesForPostTitle = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 22)]
        let size = CGSize(width: view.frame.width - 20, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributesForPostTitle, context: nil)
        return rect.height
    }
    
    private func estimateHeightForUserInfo(text: String) -> CGFloat {///
        let attributesForUserInfo = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)]
        UIFont.boldSystemFont(ofSize: 22)
        let size = CGSize(width: view.frame.width - 93, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributesForUserInfo, context: nil)
        return rect.height
    }
    
}


