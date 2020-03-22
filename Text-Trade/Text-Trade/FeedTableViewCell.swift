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
    @IBOutlet weak var contentLabel: UILabel!
    
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
    
    func setPost(post: Post){
        
        self.post = post
        self.profileImageView.image = nil
        
        ImageService.getImage(withURL: post.author.photoURL) { image, url in
            guard let _post = self.post else { return }
            if _post.author.photoURL.absoluteString == url.absoluteString {
                self.profileImageView.image = image
            } else {
                print("Not the right image")
            }
        }
        
        usernameLabel.text = post.author.username
        contentLabel.text = post.text
        subtitleLabel.text = post.createdAt.calenderTimeSinceNow()
    }
    
}
