//
//  FeedViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/8/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {


    var posts = [Post]()
    var currentPosts = [Post]()
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching: CGFloat = 3.0
    var refreshControl: UIRefreshControl?
    
    @IBOutlet weak var feedSearchBar: UISearchBar!
    @IBOutlet weak var feedSegmentedControl: UISegmentedControl!
    
    
    var postsRef: DatabaseReference {
        return Database.database().reference().child("posts")
    }
    
    var oldPostsQuery: DatabaseQuery {
        var queryRef: DatabaseQuery
        let lastPost = self.posts.last
        if lastPost != nil {
            let lastTimestamp = lastPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp")
        }
        
        return queryRef
    }
    
    var newPostsQuery: DatabaseQuery {
        var queryRef: DatabaseQuery
        let firstPost = self.posts.first
        if firstPost != nil {
            let firstTimestamp = firstPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: firstTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp")
        }
        
        return queryRef
    }
    
    
    
    var cellHeights: [IndexPath:CGFloat] = [:]

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let cellNib = UINib(nibName: "FeedTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "postCell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .normal)

        
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        //observePosts()
        
        searchBarSetup()

    }
    
    func searchBarSetup() {
        feedSearchBar.showsScopeBar = true
        feedSearchBar.selectedScopeButtonIndex = 0
        feedSearchBar.delegate = self
        //self.artistsTable.tableHeaderView = searchBar
    }
    
    
    @objc func handleRefresh(){
        print("Refresh")
        
        newPostsQuery.queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { snapshot in
                    var tempPosts = [Post]()
                    let firstPost = self.posts.first
                    
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                            let dict = childSnapshot.value as? [String:Any],
                            let post = Post.parse(childSnapshot.key, dict),
                            childSnapshot.key != firstPost?.id {
                                
                                tempPosts.insert(post, at: 0)
                            }
                    }
            
            self.posts.insert(contentsOf: tempPosts, at: 0)
            self.currentPosts = self.posts

            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        //            return completion(tempPosts)
        //            self.posts = tempPosts
        //            self.tableView.reloadData()
                    
                })
        
        
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        try! Auth.auth().signOut()
        //self.dismiss(animated: false, completion: nil)
        //self.performSegue(withIdentifier: "logOutClicked", sender: self)
    }
    
    func fetchPosts(completion:@escaping (_ posts:[Post])->()){

        oldPostsQuery.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            let lastPost = self.posts.last
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, dict),
                    childSnapshot.key != lastPost?.id {
                        
                        tempPosts.insert(post, at: 0)
                    }
            }
            return completion(tempPosts)
//            self.posts = tempPosts
//            self.tableView.reloadData()
            
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return posts.count
        
        if(section == 0){
            return currentPosts.count
        }else{
            return fetchingMore ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! FeedTableViewCell
            //cell.setPost(inputPost: posts[indexPath.row])
            cell.setPost(inputPost: currentPosts[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 72.0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
            
            if !fetchingMore && !endReached {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        fetchingMore = true
        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        
        fetchPosts { newPosts in
            self.posts.append(contentsOf: newPosts)
            self.fetchingMore = false
            self.endReached = newPosts.count == 0
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentPosts = posts
            tableView.reloadData()
            return
        }
        if(feedSegmentedControl.selectedSegmentIndex == 0){
            currentPosts = posts.filter({ (book) -> Bool in
                return book.bookTitle.lowercased().contains(searchText.lowercased()) || book.classUsedFor.lowercased().contains(searchText.lowercased())

        })
        self.tableView.reloadData()
        } else if(feedSegmentedControl.selectedSegmentIndex == 1){
            currentPosts = posts.filter({ (book) -> Bool in
                return book.bookTitle.lowercased().contains(searchText.lowercased())
            })
            self.tableView.reloadData()
            
        } else if(feedSegmentedControl.selectedSegmentIndex == 2) {
            currentPosts = posts.filter({ (book) -> Bool in
                return book.classUsedFor.lowercased().contains(searchText.lowercased())
            })
            self.tableView.reloadData()
        }

    }

}
