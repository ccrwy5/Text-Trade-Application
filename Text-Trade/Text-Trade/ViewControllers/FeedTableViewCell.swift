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
    
    var favorited = false
    
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
            
        } else {
            wishListImageView.image = UIImage(systemName: "bookmark")
            favorited = false
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
    
    func removeFavorite(){
        
    }
    
}
