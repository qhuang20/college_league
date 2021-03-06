//
//  DiscussionCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-28.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class DiscussionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    weak var discussionController: DiscussionController? {
        didSet {
//            discussionController?.searchBar?.delegate = self//deprecated
        }
    }
    
    var course: Course? {
        didSet {
            paginatePosts()
        }
    }
    
    var posts = [Post]()
    var filteredPosts = [Post]()
    var isFinishedPaging = false
    var isPaging = false
    var queryEndingValue = ""

    let cellId = "cellId"
    let cellSpacing: CGFloat = 1.5
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: UITableViewStyle.plain)
        tv.backgroundColor = brightGray
        tv.dataSource = self
        tv.delegate = self
        tv.separatorStyle = .none
        tv.rowHeight = UITableViewAutomaticDimension
        tv.estimatedRowHeight = 100
        tv.keyboardDismissMode = .onDrag
        tv.prefetchDataSource = self
        return tv
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        rc.tintColor = themeColor
        return rc
    }()
    
    let sharingHintImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "startSharingHint"))
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var dimView: UIView = {
        let dv = UIView()
        dv.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideHint)))
        return dv
    }()
    
    lazy var gotItButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Got It", for: .normal)
        button.setTitleColor(themeColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button.addTarget(self, action: #selector(hideHint), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    let loadingView = LoadingView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.backgroundView = refreshControl
        tableView.register(PostCell.self, forCellReuseIdentifier: cellId)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: PostController.updateFeedNotificationName, object: nil)
        
        addSubview(tableView)
        tableView.fillSuperview()
        
        addSubview(loadingView)
        loadingView.fillSuperview()
        
        
        
//        let headerView = UIView()///banner
//        headerView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
//        headerView.backgroundColor = UIColor.blue
//        tableView.tableHeaderView = headerView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        discussionController?.searchBar?.resignFirstResponder()
        
        let navigationController = discussionController?.navigationController
        let postContentController = PostContentController(style: UITableViewStyle.grouped)
        postContentController.post = filteredPosts[indexPath.section]
        
        navigationController?.pushViewController(postContentController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredPosts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadingIndexPath(indexPath) {
            let cell = TableViewLoadingCell(style: .default, reuseIdentifier: "loading")
            cell.isTheEnd = isFinishedPaging
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PostCell
        if filteredPosts.count > indexPath.section {
            cell.post = filteredPosts[indexPath.section]
        }
        
        return cell
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacing
    }
    
    
    
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == filteredPosts.count
    }
    
    var cellHeights: [IndexPath : CGFloat] = [:]
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
        
        guard isLoadingIndexPath(indexPath) else { return }
        if !isFinishedPaging && !isPaging {
            paginatePosts()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeights[indexPath] else { return 100 }
        return height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DiscussionCell : UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let needsFetch = indexPaths.contains { $0.section >= self.filteredPosts.count }
        if needsFetch && !isFinishedPaging && !isPaging {
            paginatePosts()
        }
    }

}






