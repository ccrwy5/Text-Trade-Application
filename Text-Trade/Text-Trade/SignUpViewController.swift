//
//  SignUpViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/8/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameTextField: UITextField!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        
        fullNameTextField.layer.borderWidth = 2
        fullNameTextField.layer.cornerRadius = 10
        fullNameTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        fullNameTextField.layer.cornerRadius = 22
        fullNameTextField.clipsToBounds = true
        fullNameTextField.attributedPlaceholder = NSAttributedString(string: "   Full Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        usernameTextField.layer.borderWidth = 2
        usernameTextField.layer.cornerRadius = 10
        usernameTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        usernameTextField.layer.cornerRadius = 22
        usernameTextField.clipsToBounds = true
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "   Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        
        emailTextField.layer.borderWidth = 2
        emailTextField.layer.cornerRadius = 10
        emailTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        emailTextField.layer.cornerRadius = 22
        emailTextField.clipsToBounds = true
        emailTextField.attributedPlaceholder = NSAttributedString(string: "   Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        passwordTextField.layer.borderWidth = 2
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        passwordTextField.layer.cornerRadius = 22
        passwordTextField.clipsToBounds = true
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "   Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        createAccountButton.layer.cornerRadius = 22
        
    }
    



}
