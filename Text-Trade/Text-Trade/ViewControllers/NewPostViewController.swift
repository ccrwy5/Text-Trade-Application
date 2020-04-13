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

//protocol NewPostVCDelegate {
//    func didUploadPost(withID id: String)
//}

class NewPostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var classUsedForTextField: UITextField!
    @IBOutlet weak var askingPriceTextField: UITextField!
    
    
    @IBOutlet weak var QRButtonImage: UIButton!
    @IBOutlet weak var QRButtonText: UIButton!
    
    //var delegate: NewPostVCDelegate?
    
    var verificationId = String()

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
        
        askingPriceTextField.layer.borderWidth = 2
        askingPriceTextField.layer.cornerRadius = 10
        askingPriceTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        askingPriceTextField.layer.cornerRadius = 22
        askingPriceTextField.clipsToBounds = true
        
    }
    
    @IBAction func handlePostButton(_ sender: Any) {
        
        guard let userProfile = UserService.currentUserProfile else { return }
        
        /* Set's the book into the posts section of DB */
        let postRef = Database.database().reference().child("posts").childByAutoId()
        let postObject = [
            "author": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString,
                "phoneNumber": userProfile.phoneNumber
            ],
            "bookTitle": titleTextField.text ?? "",
            "bookAuthor": authorTextField.text ?? "",
            "classUsedFor": classUsedForTextField.text ?? "",
            "price": askingPriceTextField.text ?? "",
            "timestamp": [".sv":"timestamp"],
            "postID": postRef.key,
            "peopleWhoLike": [""]
        ] as [String:Any]
        
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                
                self.navigationController?.popViewController(animated: true)
                //self.delegate?.didUploadPost(withID: ref.key!)
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
}
