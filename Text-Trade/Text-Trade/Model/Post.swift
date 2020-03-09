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
    var author: String
    var text: String
    
    init(id: String, author: String, text: String) {
        self.id = id
        self.author = author
        self.text = text
    }
}
