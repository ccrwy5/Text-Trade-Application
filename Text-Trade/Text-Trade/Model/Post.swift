//
//  Post.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/8/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import Foundation

class Post{
    var id: String
    var author: UserProfile
    var text: String
    var createdAt: Date

    
    init(id: String, author: UserProfile, text: String, timestamp: Double) {
        self.id = id
        self.author = author
        self.text = text
        self.createdAt = Date(timeIntervalSince1970: timestamp/1000)

    }
}
