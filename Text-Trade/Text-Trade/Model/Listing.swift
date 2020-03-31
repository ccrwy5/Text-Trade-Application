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
    
    init(id: String?, bookTitle: String?, bookAuthor: String?) {
        self.id = id
        self.bookTitle = bookTitle
        self.bookAuthor = bookAuthor
    }
    
//    static func parse(_ key:String, _ data:[String:Any]) -> Listing? {
//        
//        if let bookTitle = data["bookTitle"] as? String,
//            let bookAuthor = data["bookAuthoor"] as? String {
//            
//            return Listing( bookTitle: bookTitle, bookAuthor: bookAuthor)
//
//        }
//        
//        return nil
//    }
}
