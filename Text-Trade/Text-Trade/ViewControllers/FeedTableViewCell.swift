//
//  FeedTableViewCell.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/8/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorLabel: UILabel!
    @IBOutlet weak var classUsedForLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        
        
        
//        let starButton = UIButton(type: .system)
//        starButton.setTitle("SOME TITLE", for: .normal)
//        starButton.setImage(UIImage(named: "wishlistIcon"), for: .normal)
//        starButton.frame = CGRect(x:0, y:0, width: 50, height: 50)
//        accessoryView = starButton
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
    
}
