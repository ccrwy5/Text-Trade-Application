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
    //@IBOutlet weak var wishListImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    var postID: String!
    var favorited = false
    
    let currentUser = Auth.auth().currentUser?.uid
    let keyToPost = Database.database().reference().child("posts").childByAutoId().key

    
    override func awakeFromNib() {
        super.awakeFromNib()

        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
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
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        //let currentUserImage = Auth.auth().currentUser?.photoURL
        //self.profileImageView.load(url: currentUserImage!)
        
        usernameLabel.text = inputPost.author.username
        bookTitleLabel.text = inputPost.bookTitle
        bookAuthorLabel.text = "By: " + inputPost.bookAuthor
        classUsedForLabel.text = "Used in: " + inputPost.classUsedFor
        subtitleLabel.text = inputPost.createdAt.calenderTimeSinceNow()
        priceLabel.text = "$\(inputPost.price)"
        
    }
}
