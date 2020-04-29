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
    var seeNewPostsButton: SeeNewPostsButton!
    var seeNewPostsButtonTopAnchor: NSLayoutConstraint!
    var cellHeights: [IndexPath:CGFloat] = [:]
    
    @IBOutlet weak var feedSearchBar: UISearchBar!
    @IBOutlet weak var feedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    
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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarSetup()

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
        
        
        var layoutGuide:UILayoutGuide!
        
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            // Fallback on earlier versions
            layoutGuide = view.layoutMarginsGuide
        }
        
        seeNewPostsButton = SeeNewPostsButton()
        view.addSubview(seeNewPostsButton)
        seeNewPostsButton.translatesAutoresizingMaskIntoConstraints = false
        seeNewPostsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        seeNewPostsButtonTopAnchor = seeNewPostsButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -44)
        seeNewPostsButtonTopAnchor.isActive = true
        seeNewPostsButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        seeNewPostsButton.widthAnchor.constraint(equalToConstant: seeNewPostsButton.button.bounds.width).isActive = true
        
        seeNewPostsButton.button.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        
        beginBatchFetch()
        //handleDelete()

    }
    
    //resign keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        //searchActive = false
        self.feedSearchBar.endEditing(true)
    }
    


        

    
    func toggleSeeNewPostsButton(hidden: Bool) {
        if hidden {
            // hide it
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.seeNewPostsButtonTopAnchor.constant = -44.0
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.seeNewPostsButtonTopAnchor.constant = 112
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func searchBarSetup() {
        feedSearchBar.showsScopeBar = true
        feedSearchBar.selectedScopeButtonIndex = 0
        feedSearchBar.delegate = self
        let textFieldInsideSearchBar = feedSearchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
    }
    
    
    @objc func handleRefresh(){
        print("Refresh")
        toggleSeeNewPostsButton(hidden: true)
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


            
//            let newIndexPaths = (0..<tempPosts.count).map { i in
//                return IndexPath(row: i, section: 0)
//            }
//            self.tableView.insertRows(at: newIndexPaths, with: .top)
            self.refreshControl?.endRefreshing()
            
        })
        
        
        
        newPostsQuery.queryLimited(toFirst: 20).observeSingleEvent(of: .childRemoved, with: { snapshot in
                
            self.beginBatchFetch()
            //self.tableView.reloadData()


            self.refreshControl?.endRefreshing()
                    
                })
        
        

   
    }
    
    func handleDelete(){
        let ref = Database.database().reference().child("posts")
        ref.observeSingleEvent(of: .childRemoved, with: { snapshot in
            if let index = self.posts.firstIndex(where: {$0.id == snapshot.key}) {
                self.posts.remove(at: index) //remove it from the array via the index
                self.tableView.reloadData()
            } else {
                print("item not found)")
            }
        })
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        try! Auth.auth().signOut()
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
            //self.posts = tempPosts
//            self.tableView.reloadData()
            
        })
    }
    
    func listenForNewPosts(){
        newPostsQuery.observe(.childAdded) { (snapshot) in
            
            if snapshot.key != self.posts.first?.id,
                let data = snapshot.value as? [String:Any],
                let post = Post.parse(snapshot.key, data) {
                
                self.toggleSeeNewPostsButton(hidden: false)
            }
        }
    }
    
    func beginBatchFetch() {
        print("begin batch fetch")
        fetchingMore = true
        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        
        fetchPosts { newPosts in
            self.posts.append(contentsOf: newPosts)
            self.currentPosts.append(contentsOf: newPosts)
            self.fetchingMore = false
            self.endReached = newPosts.count == 0
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                
                self.listenForNewPosts()
            }
        }
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
    
    /*----------------- Table View -----------------------*/

    
    //Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if(section == 0){
            return currentPosts.count
        }else{
            return fetchingMore ? 1 : 0
        }
    }
    
    
    //Populate Rows and Cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! FeedTableViewCell
            handleDelete()
            cell.setPost(inputPost: currentPosts[indexPath.row])
            print("Cell set")
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
    
    
    //Click on Cell and Open Details VC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "clickedFeedCell", sender: self)
        
        let postDetailsVC = storyboard?.instantiateViewController(identifier: "PostDetailsViewController") as? PostDetailsViewController
        let post = currentPosts[indexPath.row]
        postDetailsVC?.bookTitle = post.bookTitle
        postDetailsVC?.authorName = post.bookAuthor
        postDetailsVC?.sellerName = post.author.username
        postDetailsVC?.price = post.price
        postDetailsVC?.phoneNumber = post.author.phoneNumber
        postDetailsVC?.bookImage = post.bookImage
        postDetailsVC?.email = post.author.email
        postDetailsVC?.bookCoverType = post.bookCoverType
        postDetailsVC?.bookCondition = post.bookCondition
        
        
        self.navigationController?.pushViewController(postDetailsVC!, animated: true)
    }
    
    //Cell Height
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    //Row Height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 72.0
    }
    
    @IBAction func feedSegmentedControl(_ sender: Any) {
        print("switch")
        tableView.reloadData()
    }
    
    
    /*----------------- Search Bar -----------------------*/
    
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
            
            
            
        } else if(feedSegmentedControl.selectedSegmentIndex == 2){
            
            currentPosts = posts.filter({ (book) -> Bool in
                return book.classUsedFor.lowercased().contains(searchText.lowercased())
            })
            self.tableView.reloadData()
        }
        
    }
}
