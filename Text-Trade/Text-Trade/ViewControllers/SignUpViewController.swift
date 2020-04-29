//
//  SignUpViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/8/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    var imagePicker: UIImagePickerController!
    
    var userListingsArray: [String] = []
    var userWishListArray: [String] = []

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        profileImageView.image = UIImage(named: "userIcon")
        
        createAccountButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        createAccountButton.isEnabled = false
        createAccountButton.alpha = 0.5
        
        [fullNameTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        [usernameTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        [phoneNumberTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        [emailTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        [passwordTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        
        
        
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        fullNameTextField.delegate = self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        phoneNumberTextField.delegate = self
        passwordTextField.delegate = self
        
    }


    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleSignUp() {
        guard let username = usernameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let pass = passwordTextField.text else { return }
        guard let image = profileImageView.image else { return }
        guard let phoneNumber = phoneNumberTextField.text else { return }
        guard let fullName = fullNameTextField.text else { return }
        
        
//        let email = "ccrwy5@mail.missouri.edu"
//        let suffix = String(email.suffix(18))
//        print(suffix)
        
        
        
        if emailTextField.text?.suffix(18) != "@mail.missouri.edu" {
            print("not mizzou email")
            let alertController = UIAlertController(title: "Unable to sign up", message: "Email must be a valid Mizzou email address", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        
        
        if image != UIImage(named: "userIcon") {
    
        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            
            if error == nil && user != nil {
                print("User created!")
                
                // 1. Upload the profile image to Firebase Storage
                
                self.uploadProfileImage(image) { url in
                    
                    if url != nil {
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.photoURL = url
                        
                        changeRequest?.commitChanges { error in
                            if error == nil {
                                print("User display name changed!")
                                
                                self.saveProfile(fullName: fullName, username: username, profileImageURL: url!, phoneNumber: phoneNumber, email: email) { success in
                                    if success {
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                                
                            } else {
                                print("Error: \(error!.localizedDescription)")
                                let alertController = UIAlertController(title: "Unable to sign up", message: error?.localizedDescription, preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                            
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                                
                            }
                        }
                    } else {
                        let alertController = UIAlertController(title: "Unable to add photo", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                print("Error: \(error!.localizedDescription)")
                let alertController = UIAlertController(title: "Unable to sign up", message: error!.localizedDescription , preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        } else {
            let alertController = UIAlertController(title: "Unable to sign up", message: "Must select icon picture" , preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            print("no image")
        }
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let storageRef = Storage.storage().reference().child("user/\(uid)")
            
            guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
            
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                
            storageRef.downloadURL { url, error in
                completion(url)
                // success!
                }
            } else {
                // failed
                completion(nil)
                }
            }
        }
        
    func saveProfile(fullName: String, username:String, profileImageURL:URL, phoneNumber: String, email: String, completion: @escaping ((_ success:Bool)->())) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let databaseRef = Database.database().reference().child("users/profile/\(uid)")
            
            let userObject = [
                "fullName": fullName,
                "username": username,
                "photoURL": profileImageURL.absoluteString,
                "phoneNumber": phoneNumber,
                "email": email,
                "timestamp": [".sv":"timestamp"],
                "User's Listings": [],
                "Wish list items": []
            ] as [String:Any]
            
            databaseRef.setValue(userObject) { error, ref in
                completion(error == nil)
            }
        }
    
    
        @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
            
        // Full Name
            guard let fullName = fullNameTextField.text, !fullName.isEmpty
            else {
                self.createAccountButton.isEnabled = false
                createAccountButton.alpha = 0.5
                return
            }
            createAccountButton.isEnabled = true
            createAccountButton.alpha = 1.0
           
        //Username
            guard let userName = usernameTextField.text, !userName.isEmpty
            else {
                self.createAccountButton.isEnabled = false
                createAccountButton.alpha = 0.5
                return
            }
            createAccountButton.isEnabled = true
            createAccountButton.alpha = 1.0
           
        // phone
            guard let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty
            else {
                self.createAccountButton.isEnabled = false
                createAccountButton.alpha = 0.5
                return
            }
            createAccountButton.isEnabled = true
            createAccountButton.alpha = 1.0
        
        // email
            guard let email = emailTextField.text, !email.isEmpty
            else {
                self.createAccountButton.isEnabled = false
                createAccountButton.alpha = 0.5
                return
            }
            createAccountButton.isEnabled = true
            createAccountButton.alpha = 1.0
         
            
        // password
            guard let password = passwordTextField.text, !password.isEmpty
            else {
                self.createAccountButton.isEnabled = false
                createAccountButton.alpha = 0.5
                return
            }
            createAccountButton.isEnabled = true
            createAccountButton.alpha = 1.0
    }

    
    
    func setupUI(){
        
        fullNameTextField.layer.borderWidth = 2
        fullNameTextField.layer.cornerRadius = 10
        fullNameTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        fullNameTextField.layer.cornerRadius = 18
        fullNameTextField.clipsToBounds = true
        
        usernameTextField.layer.borderWidth = 2
        usernameTextField.layer.cornerRadius = 10
        usernameTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        usernameTextField.layer.cornerRadius = 18
        usernameTextField.clipsToBounds = true
        
        phoneNumberTextField.layer.borderWidth = 2
        phoneNumberTextField.layer.cornerRadius = 10
        phoneNumberTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        phoneNumberTextField.layer.cornerRadius = 18
        phoneNumberTextField.clipsToBounds = true
        
        emailTextField.layer.borderWidth = 2
        emailTextField.layer.cornerRadius = 10
        emailTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        emailTextField.layer.cornerRadius = 18
        emailTextField.clipsToBounds = true
        
        passwordTextField.layer.borderWidth = 2
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        passwordTextField.layer.cornerRadius = 18
        passwordTextField.clipsToBounds = true
        
        createAccountButton.layer.cornerRadius = 18
    }
    
    @IBAction func phoneEntryChanged(_ sender: UITextField) {
        var text = sender.text

        if(text?.count == 3) {
            text! += "-"
            phoneNumberTextField.text = text
        } else if(text?.count == 7){
            text! += "-"
            phoneNumberTextField.text = text
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneNumberTextField {
            return range.location < 12
        } else if textField == emailTextField {
            return range.location < 30
        }
        return range.location < 20
    }
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}


