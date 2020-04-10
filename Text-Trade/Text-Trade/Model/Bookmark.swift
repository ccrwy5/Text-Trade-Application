//
//  WishListBook.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 4/9/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import Foundation

class Bookmark {

    var id: String?
    var bookTitle: String?
    var bookAuthor: String?

    init(id: String?, bookTitle: String?, bookAuthor: String?) {
        self.id = id
        self.bookTitle = bookTitle
        self.bookAuthor = bookAuthor
    }
}
