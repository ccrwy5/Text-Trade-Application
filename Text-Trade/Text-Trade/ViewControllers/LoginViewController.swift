//
//  LoginViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/8/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        emailTextField.returnKeyType = .next
        emailTextField.returnKeyType = .next
        createDoneButton()
        

    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
           if error == nil{
             //self.performSegue(withIdentifier: "alreadyLoggedIn", sender: self)
            print("logged in")
                          }
            else{
             let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
             let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            
              alertController.addAction(defaultAction)
              self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if let user = Auth.auth().currentUser {
//            self.performSegue(withIdentifier: "alreadyLoggedIn", sender: self)
//        }
    }
    
    @objc func handleSignIn() {
        guard let userName = emailTextField.text else { return }
        guard let pass = passwordTextField.text else { return }
        
        //setContinueButton(enabled: false)
        //continueButton.setTitle("", for: .normal)
        //activityView.startAnimating()
        
        Auth.auth().signIn(withEmail: userName, password: pass) { user, error in
            if error == nil && user != nil {
                self.dismiss(animated: false, completion: nil)
            } else {
                print("Error logging in: \(error!.localizedDescription)")
            }
        }
    }
    
    
    func setupUI(){
        emailTextField.layer.borderWidth = 2
        emailTextField.layer.cornerRadius = 10
        emailTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        emailTextField.layer.cornerRadius = 22
        emailTextField.clipsToBounds = true
        //emailTextField.attributedPlaceholder = NSAttributedString(string: "   Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        passwordTextField.layer.borderWidth = 2
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        passwordTextField.layer.cornerRadius = 22
        passwordTextField.clipsToBounds = true
        //passwordTextField.attributedPlaceholder = NSAttributedString(string: "   Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        loginButton.layer.cornerRadius = 22

    }
    
    func createDoneButton(){
        let toolBar = UIToolbar()
            toolBar.sizeToFit()
        
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
            
            toolBar.setItems([flexibleSpace, doneButton], animated: false)
            emailTextField.inputAccessoryView = toolBar
            passwordTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneClicked(){
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField == emailTextField {
         textField.resignFirstResponder()
         passwordTextField.becomeFirstResponder()
      } else if textField == passwordTextField {
         textField.resignFirstResponder()
      }
     return true
    }
    



}
