//
//  FeedViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/8/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    var posts = [
        Post(id: "1", author: "Chris Rehagen", text: "Testing"),
        Post(id: "2", author: "Testing ", text: "Phi Delta Theta (ΦΔΘ), commonly known as Phi Delt, is an international social fraternity founded at Miami University in 1848 and headquartered in Oxford, Ohio."),
        Post(id: "3", author: "Testing", text: "Phi Delta Theta, along with Beta Theta Pi and Sigma Chi form the Miami Triad")
    ]

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let cellNib = UINib(nibName: "FeedTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "postCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()

    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        try! Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
        self.performSegue(withIdentifier: "logOutClicked", sender: self)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! FeedTableViewCell
        cell.setPost(post: posts[indexPath.row])
        return cell
    }

}
