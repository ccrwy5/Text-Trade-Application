//
//  PostDetailsViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 4/6/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import MessageUI

class PostDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    //@IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var openBrowserButton: UIButton!
    @IBOutlet weak var bookCoverTypeLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    
    
    var bookTitle: String = ""
    var authorName: String = ""
    var sellerName: String = ""
    var price: String = ""
    var phoneNumber: String = ""
    var email: String = ""
    var bookImage: URL? = nil
    var bookCoverType: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        titleLabel.text = bookTitle
        authorLabel.text = "By: \(authorName)"
        //sellerLabel.text = "Seller: \(sellerName)" 
        priceLabel.text = "Price: $\(price)"
        //phoneNumberLabel.text = "Email: \(email)"
        bookCoverTypeLabel.text = bookCoverType
        emailButton.setTitle(email, for: .normal)
        
        
        ImageService.getImage(withURL: bookImage!) { image, url in
                self.bookImageView.image = image
            }
        }
    
    @IBAction func emailButtonPressed(_ sender: Any) {
        guard MFMailComposeViewController.canSendMail() else {
            //show alert
            print("error")
            return
        }
        
        print("called")
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([email])
        composer.setSubject("Your Text-Trade listing")
        composer.setMessageBody("Your Text-Trade listing: \(String(describing: bookTitle))", isHTML: false)
        
        present(composer, animated: true)
    }
    
    
    func setupUI(){
        bookImageView.layer.cornerRadius = 20
        bookImageView.clipsToBounds = true
        openBrowserButton.layer.cornerRadius = 10
    }
    
    @IBAction func openBrowserButtonClicked(_ sender: Any) {
        let begining = "https://www.google.com/search?psb=1&tbm=shop&q="
        let title: String = bookTitle
        let formattedString = title.replacingOccurrences(of: " ", with: "%20")
        
        let googleLink = "\(begining)\(formattedString)%20book"
        //print(googleLink)
        
        
        UIApplication.shared.open(URL(string: googleLink)!, options: [:], completionHandler: nil)
    }
    
}

extension PostDetailsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            //show alert error
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        case .saved:
            print("saved")
        case .sent:
            print("sent")
        }
        controller.dismiss(animated: true)
        
    }
}
