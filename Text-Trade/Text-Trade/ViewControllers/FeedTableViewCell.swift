//
//  FeedTableViewCell.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/8/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Firebase

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorLabel: UILabel!
    @IBOutlet weak var classUsedForLabel: UILabel!
    @IBOutlet weak var wishListImageView: UIImageView!
    
    var postID: String!
    var favorited = false
    
    let currentUser = Auth.auth().currentUser?.uid
    
    override func awakeFromNib() {
        super.awakeFromNib()

        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        wishListImageView.isUserInteractionEnabled = true
        wishListImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    weak var post:Post?
    
    func setPost(inputPost: Post){
        
        self.post = inputPost
        self.profileImageView.image = nil
        
        ImageService.getImage(withURL: inputPost.author.photoURL) { image, url in
            guard let _post = self.post else { return }
            if _post.author.photoURL.absoluteString == url.absoluteString {
                self.profileImageView.image = image
            } else {
                print("Not the right image")
            }
        }
        
        usernameLabel.text = inputPost.author.username
        bookTitleLabel.text = inputPost.bookTitle
        bookAuthorLabel.text = "By: " + inputPost.bookAuthor
        classUsedForLabel.text = "Used in: " + inputPost.classUsedFor
        subtitleLabel.text = inputPost.createdAt.calenderTimeSinceNow()
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

        if(favorited == false){
            wishListImageView.image = UIImage(systemName: "bookmark.fill")
            favorited = true
            setFavorite()
            addBookmark()
            
        } else {
            wishListImageView.image = UIImage(systemName: "bookmark")
            favorited = false
            removeBookmark()
        }
    }
    
    func setFavorite(){
        /* Set's the book into the user's listings section of DB */
        
        let currentUser = (Auth.auth().currentUser?.uid)!
        let wishListDatabaseRef = Database.database().reference().child("users").child("profile").child(currentUser).child("Wish list items").childByAutoId()
        
        let wishListObject = [
                "id": wishListDatabaseRef.key,
                "bookTitle": bookTitleLabel.text ?? "",
                "bookAuthor": bookAuthorLabel.text ?? ""
                
        ] as [String: Any]
        
        wishListDatabaseRef.setValue(wishListObject)
    }
    
    func addBookmark(){
        let ref = Database.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key

        ref.child("posts").child(self.postID).observeSingleEvent(of: .value) { (snapshot) in
            if let post = snapshot.value as? [String: AnyObject] {
                let updateBookmarks: [String: Any] = ["peopleWhoBookmark/\(keyToPost!)": self.currentUser!]
                ref.child("posts").child(self.postID).updateChildValues(updateBookmarks) { (error, reference) in

                    if error == nil {
                        ref.child("posts").child(self.postID).observeSingleEvent(of: .value) { (snap) in
                            if let properties = snap.value as? [String: AnyObject] {
                                if let likes = properties["peopleWhoBookmark"] as? [String: AnyObject] {
                                    let count = likes.count
                                    print("Likes: \(count)")

                                    let update = ["likes": count]
                                    ref.child("posts").child(self.postID).updateChildValues(update)
                                }
                            }
                        }
                    }
                }

            }
        }

        ref.removeAllObservers()
    }

    func removeBookmark(){
        let ref = Database.database().reference()
        
        
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let properties = snapshot.value as? [String : AnyObject] {
                if let peopleWhoBookmark = properties["peopleWhoBookmark"] as? [String : AnyObject] {
                    for (id,person) in peopleWhoBookmark {
                        if person as? String == Auth.auth().currentUser!.uid {
                            ref.child("posts").child(self.postID).child("peopleWhoBookmark").child(id).removeValue(completionBlock: { (error, reff) in
                                if error == nil {
                                    ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                                        if let prop = snap.value as? [String : AnyObject] {
                                            if let likes = prop["peopleWhoBookmark"] as? [String : AnyObject] {
                                                let count = likes.count
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : count])
                                            }else {
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : 0])
                                            }
                                        }
                                    })
                                }
                            })

                            break
                        }
                    }
                }
            }
            
        })
        ref.removeAllObservers()
    }
}
