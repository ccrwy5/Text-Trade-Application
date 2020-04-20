//
//  PostDetailsViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 4/6/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit

class PostDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    
    
    var bookTitle: String = ""
    var authorName: String = ""
    var sellerName: String = ""
    var price: String = ""
    var phoneNumber: String = ""
    var bookImage: URL? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        titleLabel.text = bookTitle
        authorLabel.text = "By: \(authorName)"
        sellerLabel.text = "Seller: \(sellerName)"
        priceLabel.text = "Price: $\(price)"
        phoneNumberLabel.text = "Phone Number: \(phoneNumber)"
        
        
        ImageService.getImage(withURL: bookImage!) { image, url in
                self.bookImageView.image = image
            }
        }
    
    
    func setupUI(){
        bookImageView.layer.cornerRadius = 20
        bookImageView.clipsToBounds = true
    }
}
