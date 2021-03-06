//
//  PostContentController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-06.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import AMScrollingNavbar
import Firebase
import ImageViewer
import LBTAComponents

extension UIImageView: DisplaceableView {}

struct DataItem {
    let imageView: CachedImageView
    let galleryItem: GalleryItem
}

class PostContentController: UITableViewController {
    
    var items: [DataItem] = []//ImageViewer
    
    var post: Post?
    var postMessages = [PostMessage]()
    
    var responseArr = [Response]()
    var responseMessagesDic = [String: [ResponseMessage]]()
    var isFinishedPaging = false
    var isPaging = true//fetchPostAndResponse
    var queryEndingValue = ""
    
    let postHeaderCellId = "postHeaderCellId"
    let postMessageCellId = "postMessageCellId"
    let responseHeaderCellId = "responseHeaderCellId"
    let responseMessageCellId = "responseMessageCellId"
    let cellSpacing: CGFloat = 5
    
    let loadingView = LoadingView()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        view.addSubview(loadingView)
        loadingView.fillSuperview()
        loadingView.anchorCenterSuperview()
        
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(tableView, delay: 10, followers: [NavigationBarFollower(view: tabBarController!.tabBar)])
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdate), name: ResponseController.updateResponseNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateResponseCount), name: ResponseController.updateResponseCountName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePostLikesCount), name: PostFooterView.updatePostLikesCountName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFollowButtonStyle), name: UserProfileHeader.updateUserFollowingNotificationName, object: nil)
        
        fetchPostAndResponse()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureTableView() {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))//ios10
        
        tableView.backgroundColor = brightGray
        tableView.contentInset = UIEdgeInsets.zero
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 125
        tableView.prefetchDataSource = self
        tableView.register(PostHeaderCell.self, forCellReuseIdentifier: postHeaderCellId)
        tableView.register(PostMessageCell.self, forCellReuseIdentifier: postMessageCellId)
        tableView.register(ResponseHeaderCell.self, forCellReuseIdentifier: responseHeaderCellId)
        tableView.register(ResponseMessageCell.self, forCellReuseIdentifier: responseMessageCellId)
    }
    
    @objc private func handleUpdateFollowButtonStyle(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let user = userInfo["user"] as? User else { return }
        checkAllUsersToUpdateFollowButton(user: user)
    }
    
    private func checkAllUsersToUpdateFollowButton(user: User) {
        let hasFollowedNewState = user.hasFollowed
        let uid = user.uid
        
        if post?.user.uid == uid {
            post?.user.hasFollowed = hasFollowedNewState
        }
        responseArr.forEach({ (response) in
            if response.user.uid == uid {
                let i = responseArr.index(of: response)
                responseArr[i!].user.hasFollowed = hasFollowedNewState
            }
        })
        
        tableView.reloadData()
    }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return responseArr.count + 1 + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let indexPath = IndexPath(row: 0, section: section)
        if isLoadingIndexPath(indexPath) {
            return 1
        }
        
        if section == 0 {
            return postMessages.count + 1
        }
        
        let responseId = responseArr[section - 1].responseId
        if let count = responseMessagesDic[responseId]?.count {
            return count + 1
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadingIndexPath(indexPath) {
            let cell = TableViewLoadingCell(style: .default, reuseIdentifier: "loading")
            cell.isTheEnd = isFinishedPaging
            cell.theEndLabel.text = "no more response"
            return cell
        }
        
        let topIndexPath = IndexPath(row: 0, section: 0)
        let section = indexPath.section
        let row = indexPath.row
       
        if indexPath == topIndexPath {
            let cell = tableView.dequeueReusableCell(withIdentifier: postHeaderCellId, for: indexPath) as! PostHeaderCell
            cell.post = post
            cell.postContentController = self
            return cell
        }
        
        if section == 0 && row >= 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: postMessageCellId, for: indexPath) as! PostMessageCell
            cell.postMessage = postMessages[row - 1]
            cell.postContentController = self
            return cell
        }
        
        if section >= 1 && row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: responseHeaderCellId, for: indexPath) as! ResponseHeaderCell
            cell.response = responseArr[section - 1]
            cell.postContentController = self
            return cell
        }
        
        if section >= 1 && row >= 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: responseMessageCellId, for: indexPath) as! ResponseMessageCell
            let responseId = responseArr[section - 1].responseId
            cell.responseMessage = responseMessagesDic[responseId]?[row - 1]
            cell.postContentController = self
            return cell
        }
        
        let cell = UITableViewCell()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let indexPath = IndexPath(row: 0, section: section)
        if isLoadingIndexPath(indexPath) {
            return UIView()
        }
        
        if section == 0 {
            let postFooter = PostFooterView()
            postFooter.postContentController = self
            postFooter.post = post
            
            if loadingView.alpha == 1 {
                postFooter.isHidden = true
            }
            return postFooter
        }
        
        let responseFooter = ResponseFoonterView()
        let response = responseArr[section - 1]
        responseFooter.postContentController = self
        responseFooter.response = response
        return responseFooter
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return cellSpacing
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
        
        guard isLoadingIndexPath(indexPath) else { return }
        if !isFinishedPaging && !isPaging {
            paginateResponse()
        }
    }

    var cellHeights: [IndexPath : CGFloat] = [:]
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeights[indexPath] else { return 100 }
        return height
    }
    
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == responseArr.count + 1
    }
    
}

extension PostContentController : UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let needsFetch = indexPaths.contains { $0.section >= self.responseArr.count }
        if needsFetch && !isFinishedPaging && !isPaging {
            paginateResponse()
        }
    }
    
}












