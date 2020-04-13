//
//  UserService.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/20/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import Foundation
import Firebase


class UserService {
    
    static var currentUserProfile:UserProfile?
    
    static func observeUserProfile(_ uid:String, completion: @escaping ((_ userProfile:UserProfile?)->())) {
        let userRef = Database.database().reference().child("users/profile/\(uid)")
        
        userRef.observe(.value, with: { snapshot in
            var userProfile:UserProfile?
            
            if let dict = snapshot.value as? [String:Any],
                let username = dict["username"] as? String,
                let photoURL = dict["photoURL"] as? String,
                let phoneNumber = dict["phoneNumber"] as? String,
                let url = URL(string:photoURL) {
                
                userProfile = UserProfile(uid: snapshot.key, username: username, photoURL: url, phoneNumber: phoneNumber)
            }
            
            completion(userProfile)
        })
    }
    
}
