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
    var bookTitle: String
    var createdAt: Date
    var bookAuthor: String
    var classUsedFor: String
    var postID: String
    var price: String
    
    
    var peopleWhoLike: [String] = [String]()

    
    init(id: String, author: UserProfile, bookTitle: String, timestamp: Double, bookAuthor: String, classUsedFor: String, postID: String, peopleWhoLike: [String], price: String) {
        self.id = id
        self.author = author
        self.bookTitle = bookTitle
        self.createdAt = Date(timeIntervalSince1970: timestamp/1000)
        self.bookAuthor = bookAuthor
        self.classUsedFor = classUsedFor
        self.postID = postID
        self.peopleWhoLike = peopleWhoLike
        self.price = price
        
    }
    
    static func parse(_ key:String, _ data:[String:Any]) -> Post? {
        
        if let author = data["author"] as? [String:Any],
            let uid = author["uid"] as? String,
            let username = author["username"] as? String,
            let photoURL = author["photoURL"] as? String,
            let url = URL(string:photoURL),
            let bookTitle = data["bookTitle"] as? String,
            let timestamp = data["timestamp"] as? Double,
            let bookAuthor = data["bookAuthor"] as? String,
            let classUsedFor = data["classUsedFor"] as? String,
            let postID = data["postID"] as? String,
            let peopleWhoLike = data["peopleWhoLike"] as? [String],
            let price = data["price"] as? String {
            
            let userProfile = UserProfile(uid: uid, username: username, photoURL: url)
            return Post(id: key, author: userProfile, bookTitle: bookTitle, timestamp:timestamp, bookAuthor: bookAuthor, classUsedFor: classUsedFor, postID: postID, peopleWhoLike: peopleWhoLike, price: price)
            
        }
        
        return nil
    }
}
