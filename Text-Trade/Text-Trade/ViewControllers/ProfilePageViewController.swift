//
//  ProfilePageViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/23/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Firebase

class ProfilePageViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var listABookButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var wishListButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCurrentProfileInfo()
        
        listABookButton.layer.cornerRadius = 10
        logoutButton.layer.cornerRadius = 10
        wishListButton.layer.cornerRadius = 10

    }
    
    
    @IBAction func handleLogoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
    }
    
    func loadCurrentProfileInfo(){
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        let currentUserImage = Auth.auth().currentUser?.photoURL
        self.profileImageView.load(url: currentUserImage!)
        
        usernameLabel.text = Auth.auth().currentUser?.displayName

    }
    
 
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
