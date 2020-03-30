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
    
    var userListedBooksArray: [String] = []
    var userWishListArray: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCurrentProfileInfo()
        segmentedControl.selectedSegmentIndex = 0
        addDummyListing()
        addDummyWishListItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
      }
    
    @IBAction func handleSegmentChange(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            addDummyListing()
            listTableView.reloadData()
            print(userListedBooksArray)
        } else if sender.selectedSegmentIndex == 1 {
            addDummyWishListItem()
            listTableView.reloadData()
            print(userWishListArray)
        }
    }
    
    
    func loadCurrentProfileInfo(){
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        let currentUserImage = Auth.auth().currentUser?.photoURL
        self.profileImageView.load(url: currentUserImage!)
        
        usernameLabel.text = Auth.auth().currentUser?.displayName
    }
    
    func addDummyListing(){
        let currentUser = (Auth.auth().currentUser?.uid)!
        let listingDatabaseRef = Database.database().reference().child("users").child("profile").child(currentUser).child("User's Listings")
        
        userListedBooksArray = ["book1", "book2"]
        
        listingDatabaseRef.setValue(userListedBooksArray)

    }
    
    func addDummyWishListItem(){
        let currentUser = (Auth.auth().currentUser?.uid)!
        let wishListDatabaseRef = Database.database().reference().child("users").child("profile").child(currentUser).child("Wish list items")

        userWishListArray = ["book3", "book4", "book5"]
        
        wishListDatabaseRef.setValue(userWishListArray)
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
            numberOfRows = userListedBooksArray.count
        } else if segmentedControl.selectedSegmentIndex == 1 {
            numberOfRows = userWishListArray.count
        }
        
        return numberOfRows
    }

    // Populate Cells from Arrays
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = listTableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            cell.textLabel?.text = userListedBooksArray[indexPath.row]
        } else if segmentedControl.selectedSegmentIndex == 1 {
            cell.textLabel?.text = userWishListArray[indexPath.row]
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
