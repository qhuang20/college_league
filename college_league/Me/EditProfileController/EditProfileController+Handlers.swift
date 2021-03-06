//
//  EditProfileController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-29.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension EditProfileController: UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSave() {
        if (wordsLimitForBio - bioTextView.text.count) < 0 {
            popUpErrorView(text: "Reach Words Limit")
            return
        }
        if nameTextField.text?.count == 0 {
            popUpErrorView(text: "Enter Your Name")
            return
        }
        if (nameTextField.text?.count) ?? 0 > 15 {
            popUpErrorView(text: "Your name is too long")
            return
        }
        UserDefaults.standard.setEyeSelected(value: false)
        
        guard let username = nameTextField.text else { return }
        guard let image = self.profileImageView.image else { return }
        let bio = bioTextView.text
        let school = self.schoolLabel.text
        let saveButton = navigationItem.rightBarButtonItem
        saveButton?.tintColor = brightGray
        saveButton?.isEnabled = false
        let cancelButton = navigationItem.leftBarButtonItem
        cancelButton?.isEnabled = false
        _ = getActivityIndicator()
        view.endEditing(true)
        
        guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child(filename)
        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
            if let err = err {
                print("Failed to upload profile image:", err)
                return
            }
            
            storageRef.downloadURL { (url, err) in
                guard let profileImageUrl = url?.absoluteString else { return }
                print("Successfully uploaded profile image:", profileImageUrl)
                
                let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl, "bio": bio as Any, "school": school as Any] as [String : Any]
                self.updateUsersValuesToDatabase(values: dictionaryValues)
            }
        })
    }
    
    private func updateUsersValuesToDatabase(values: [String: Any]) {
        guard let uid = user?.uid else { return }
        Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print("Failed to save user info into db:", err)
                return
            }
            print("Successfully saved user info to db")
            
            if let school = self.schoolLabel.text {
                UserDefaults.standard.setSchool(value: school)
                let ref = Database.database().reference().child("school_users").child(school)
                ref.updateChildValues([uid : 1])
            }
            
            
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleCanel() {
        view.endEditing(true)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func handleSetSchool() {
        let setSchoolController = SetSchoolController()
        setSchoolController.editProfileController = self
        
        let navSetSchoolController = UINavigationController(rootViewController: setSchoolController)
        navSetSchoolController.modalPresentationStyle = .overFullScreen
        navSetSchoolController.modalTransitionStyle = .crossDissolve
        present(navSetSchoolController, animated: true, completion: nil)
    }

    @objc func handleSetSkills() {
        let setSkillsController = SetSkillsController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(setSkillsController, animated: true)
    }
    
    
    
    @objc func handleSelectProfileImageView() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        textCountLabel.text = "\(wordsLimitForBio - textView.text.count)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
}

