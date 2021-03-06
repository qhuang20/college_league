//
//  ViewController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-24.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

let hoursBarWidth: CGFloat = 36
let daysBarHeight: CGFloat = 36
let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri"]
let hours = ["8", "9", "10", "11", "12", "1", "2", "3", "4", "5", "6", "7"]

class TimetableController: DatasourceController {
    
    let navbarHeight: CGFloat = 0
    var navbar: UINavigationBar!
    
    let daysBar: UIStackView = {
        var views = [UIView]()
        for i in 0...weekdays.count - 1 {
            let label = UILabel()
            label.backgroundColor = themeColor
            label.text = weekdays[i]
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textAlignment = .center
            views.append(label)
        }
        
        let sv = UIStackView(arrangedSubviews: views)
        sv.distribution = .fillEqually
        return sv
    }()
    
    let hoursBar: UIStackView = {
        var views = [UIView]()
        for i in 0...11 {
            let label = UILabel()
            label.backgroundColor = themeColor
            label.text = hours[i]
            label.textColor = UIColor.white
            label.textAlignment = .center
            views.append(label)
        }
        
        let sv = UIStackView(arrangedSubviews: views)
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.layer.cornerRadius = 10
        sv.clipsToBounds = true
        return sv
    }()
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = TimetableDatasource()
        transitioningDelegate = self
        
        configureNavigationItems()
        
        configureCollectionView()

        setupTimeBars()
        
        if let savedWeekCourses = (datasource as! TimetableDatasource).loadWeekCourses() {
            (datasource as! TimetableDatasource).weekCourses = savedWeekCourses
        }
    }
    
    private func configureNavigationItems() {
        navbar = navigationController?.navigationBar
        navbar.backgroundColor = themeColor
        navigationItem.title = " Time Table"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addCourse").withRenderingMode(.alwaysTemplate), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addNewCourse))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "rightArrow").withRenderingMode(.alwaysTemplate), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    private func configureCollectionView() {
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = -0.5
        layout.minimumInteritemSpacing = 0.0
        collectionView?.isScrollEnabled = false
        collectionView?.backgroundColor = themeColor
        collectionView?.contentInset = UIEdgeInsets(top: daysBarHeight + navbarHeight, left: hoursBarWidth + 2, bottom: 0, right: 0)//only can do one side (no shrink)
    }
    
    private func setupTimeBars() {
        view.addSubview(hoursBar)
        view.addSubview(daysBar)
        
        daysBar.anchor(view.safeAreaTopAnchor, left: hoursBar.rightAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: daysBarHeight)
        hoursBar.anchor(daysBar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaBottomAnchor, right: nil, topConstant: -16, leftConstant: 0, bottomConstant: 16, rightConstant: 0, widthConstant: hoursBarWidth, heightConstant: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            height = view.safeAreaLayoutGuide.layoutFrame.height - daysBarHeight - navbarHeight
        } else {
            height = view.frame.height - daysBarHeight - navbarHeight
        }
        let width = (view.frame.width - hoursBarWidth) / CGFloat(weekdays.count)
        
        return CGSize(width: width, height: height)
    }
    
}





