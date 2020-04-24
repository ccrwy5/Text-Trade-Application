//
//  PostToListing.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/30/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import Foundation

class Listing {
    var id: String?
    var bookTitle: String?
    var bookAuthor: String?
    var price: String?
    
    init(id: String?, bookTitle: String?, bookAuthor: String?, price: String?) {
        self.id = id
        self.bookTitle = bookTitle
        self.bookAuthor = bookAuthor
        self.price = price
    }
}
