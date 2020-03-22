//
//  FeedViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/8/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    var posts = [Post]()
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching: CGFloat = 3.0
    
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
        
        //observePosts()

    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        try! Auth.auth().signOut()
        //self.dismiss(animated: false, completion: nil)
        //self.performSegue(withIdentifier: "logOutClicked", sender: self)
    }
    
    func fetchPosts(completion:@escaping (_ posts:[Post])->()){
        let postsRef = Database.database().reference().child("posts")
        let lastPost = self.posts.last
        var queryRef: DatabaseQuery
        if lastPost != nil {
            let lastTimestamp = lastPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp).queryLimited(toLast: 20)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryLimited(toLast: 20)

        }
        
            queryRef.observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String:Any],
                    let author = dict["author"] as? [String:Any],
                    let uid = author["uid"] as? String,
                    let username = author["username"] as? String,
                    let photoURL = author["photoURL"] as? String,
                    let url = URL(string:photoURL),
                    let text = dict["text"] as? String,
                    let timestamp = dict["timestamp"] as? Double {
                    
                    if childSnapshot.key != lastPost?.id {
                        let userProfile = UserProfile(uid: uid, username: username, photoURL: url)
                        let post = Post(id: childSnapshot.key, author: userProfile, text: text, timestamp:timestamp)
                        tempPosts.insert(post, at: 0)
                    }
                    

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
            return posts.count
        }else{
            return fetchingMore ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! FeedTableViewCell
            cell.setPost(post: posts[indexPath.row])
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

}
