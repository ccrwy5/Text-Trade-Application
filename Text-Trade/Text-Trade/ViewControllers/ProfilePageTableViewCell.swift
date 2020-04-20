//
//  ProfilePageTableViewCell.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/31/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit

class ProfilePageTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
