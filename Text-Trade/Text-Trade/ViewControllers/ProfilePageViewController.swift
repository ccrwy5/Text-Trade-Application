//
//  ProfilePageViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/23/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Firebase

class ProfilePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    //var listings = [Listing]()
    var listingReference: DatabaseReference!
    var bookmarkReference: DatabaseReference!
    
    
    var listingsList = [Listing]()
    var bookmarkList: [Bookmark] = []

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCurrentProfileInfo()
        segmentedControl.selectedSegmentIndex = 0
 
        populateListings()
        populateBookmarks()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
      }
    
    @IBAction func handleSegmentChange(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            populateListings()
            listTableView.reloadData()
        } else if sender.selectedSegmentIndex == 1 {
            populateBookmarks()
            listTableView.reloadData()
            print(bookmarkList)
        }
    }
    
    
    func loadCurrentProfileInfo(){
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        let currentUserImage = Auth.auth().currentUser?.photoURL
        self.profileImageView.load(url: currentUserImage!)
        
        usernameLabel.text = Auth.auth().currentUser?.displayName
    }
    
    func populateListings(){
        let currentUser = (Auth.auth().currentUser?.uid)!
        listingReference = Database.database().reference().child("users").child("profile").child(currentUser).child("User's Listings")
        
        listingReference.observe(.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                self.listingsList.removeAll()
                
                for listing in snapshot.children.allObjects as! [DataSnapshot] {
                    let listingObject = listing.value as? [String:AnyObject]
                    let name = listingObject?["bookTitle"]
                    let genre = listingObject?["bookAuthor"]
                    let id = listingObject?["id"]
                    
                    let artist = Listing(id: id as! String?, bookTitle: name as! String?, bookAuthor: genre as! String?)
                    
                    self.listingsList.append(artist)
                }
                self.listTableView.reloadData()
            }
        })

    }
    
    
    func populateBookmarks(){
        let currentUser = (Auth.auth().currentUser?.uid)!
        bookmarkReference = Database.database().reference().child("users").child("profile").child(currentUser).child("Wish list items")
        
        bookmarkReference.observe(.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                self.bookmarkList.removeAll()
                
                for book in snapshot.children.allObjects as! [DataSnapshot] {
                    let wishListObject = book.value as? [String:AnyObject]
                    let name = wishListObject?["bookTitle"]
                    let genre = wishListObject?["bookAuthor"]
                    let id = wishListObject?["id"]
                    
                    let item = Bookmark(id: id as! String?, bookTitle: name as! String?, bookAuthor: genre as! String?)
                    
                    self.bookmarkList.append(item)
                }
                self.listTableView.reloadData()
            }
        })


    }
    
    /* -------- Table View Functions -------- */
    
    // Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        
        if segmentedControl.selectedSegmentIndex == 0 {
            numberOfRows = listingsList.count
            print("Number of rows: \(numberOfRows)")
            print("Contents: \(listingsList)")

            
        } else if segmentedControl.selectedSegmentIndex == 1 {
            numberOfRows = bookmarkList.count
            print("Number of rows: \(numberOfRows)")
            print("Contents: \(bookmarkList)")
        }
        
        return numberOfRows
    }
    
    // Populate Cells from Arrays
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = listTableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfilePageTableViewCell
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            let listing: Listing
            listing = listingsList[indexPath.row]
            cell.titleLabel.text = listing.bookTitle
            
            
        } else if segmentedControl.selectedSegmentIndex == 1 {
            
            let bookmarkItem: Bookmark
            bookmarkItem = bookmarkList[indexPath.row]
            cell.titleLabel.text = bookmarkItem.bookTitle
        }
            return cell
    }

    // Header Title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sectionDifference = ""
        let currentUser = Auth.auth().currentUser?.displayName

        if segmentedControl.selectedSegmentIndex == 0 {
            sectionDifference = "is selling"
        } else if segmentedControl.selectedSegmentIndex == 1 {
            sectionDifference =  "wants to find"
        }
        return "Books that \(currentUser ?? "user") \(sectionDifference)"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
        if segmentedControl.selectedSegmentIndex == 0 {
            let currentUser = Auth.auth().currentUser?.displayName
            let postDetailsVC = storyboard?.instantiateViewController(identifier: "PostDetailsViewController") as? PostDetailsViewController
            //let post = posts[indexPath.row]
            let listing = listingsList[indexPath.row]
            postDetailsVC?.bookTitle = listing.bookTitle!
            postDetailsVC?.authorName = listing.bookAuthor!
            postDetailsVC?.sellerName = currentUser!
            self.navigationController?.pushViewController(postDetailsVC!, animated: true)

            
            
        } else if segmentedControl.selectedSegmentIndex == 1 {
            
        }
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
