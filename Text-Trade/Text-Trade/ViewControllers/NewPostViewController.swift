//
//  NewPostViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/20/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class NewPostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var classUsedForTextField: UITextField!
    
    @IBOutlet weak var QRButtonImage: UIButton!
    @IBOutlet weak var QRButtonText: UIButton!
    
    var verificationId = String()
    //var allUsersListings = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let testString = verificationId

        let array = testString.components(separatedBy: "by ")
        //print(array)
        let title = array.first!
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        let author = array.last!
        
        titleTextField.text = trimmedTitle
        authorTextField.text = author
        
        setupUI()
        //getAllUserListings()
        //getAllUserListings2()

    }
    
    func setupUI(){
        titleTextField.layer.borderWidth = 2
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        titleTextField.layer.cornerRadius = 22
        titleTextField.clipsToBounds = true
        
        authorTextField.layer.borderWidth = 2
        authorTextField.layer.cornerRadius = 10
        authorTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        authorTextField.layer.cornerRadius = 22
        authorTextField.clipsToBounds = true
        
        classUsedForTextField.layer.borderWidth = 2
        classUsedForTextField.layer.cornerRadius = 10
        classUsedForTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        classUsedForTextField.layer.cornerRadius = 22
        classUsedForTextField.clipsToBounds = true
        
    }
    
    @IBAction func handlePostButton(_ sender: Any) {
        
        guard let userProfile = UserService.currentUserProfile else { return }
        
        /* Set's the book into the posts section of DB */
        let postRef = Database.database().reference().child("posts").childByAutoId()
        let postObject = [
            "author": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ],
            "bookTitle": titleTextField.text ?? "",
            "bookAuthor": authorTextField.text ?? "",
            "classUsedFor": classUsedForTextField.text ?? "",
            "timestamp": [".sv":"timestamp"]
        ] as [String:Any]
        
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            } else {
                print("error in postRef setValue")
            }
        })
        
        /* Set's the book into the user's listings section of DB */
        
        let currentUser = (Auth.auth().currentUser?.uid)!
        let listingDatabaseRef = Database.database().reference().child("users").child("profile").child(currentUser).child("User's Listings").childByAutoId()
        
        let listingObject = [
                "id": listingDatabaseRef.key,
                "bookTitle": titleTextField.text ?? "",
                "bookAuthor": authorTextField.text ?? ""
        ] as [String: Any]
        
        listingDatabaseRef.setValue(listingObject)

    }
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        //textView.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            super.dismiss(animated: flag, completion: completion)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //textView.becomeFirstResponder()
        
    }
    
    @IBAction func QRButtonImagePressed(_ sender: Any) {
    }
    
    @IBAction func QRButtonTextPressed(_ sender: Any) {
    }
    
//    func getAllUserListings() {
//        let currentUser = (Auth.auth().currentUser?.uid)!
//        let listingDatabaseRef = Database.database().reference().child("users").child("profile").child(currentUser).child("User's Listings")
//
//        listingDatabaseRef.observeSingleEvent(of: .value) { (snapshot) in
//            for child in snapshot.children {
//                let snap = child as! DataSnapshot
//                //let key = snap.key
//                let value = snap.value!
//                //print(value)
//
//            }
//        }
//    }
//
//
//    var listingsList = [Listing]()
//    func getAllUserListings2(){
//        let currentUser = (Auth.auth().currentUser?.uid)!
//        let listingDatabaseRef = Database.database().reference().child("users").child("profile").child(currentUser).child("User's Listings")
//
//        listingDatabaseRef.observe(.value) { (snapshot) in
//            if snapshot.childrenCount > 0 {
//
//                self.listingsList.removeAll()
//
//                for listing in snapshot.children.allObjects as! [DataSnapshot] {
//                    let listingObject = listing.value as? [String: Any]
//                        let bookTitle = listingObject?["bookTitle"]
//                        let bookAuthor = listingObject?["bookAuthor"]
//                        let id = listingObject?["id"]
//
//                    let newListing = Listing(id: id as? String, bookTitle: bookTitle as? String, bookAuthor: bookAuthor as? String)
//                    self.listingsList.append(newListing)
//                    //print(self.listingsList)
//
//                    print("\(self.listingsList)")
//                }
//
//
//
//
//            }
//        }
//    }
    
    
    
}
