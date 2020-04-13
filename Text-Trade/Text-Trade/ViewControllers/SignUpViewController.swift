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
        
        createAccountButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
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
                
        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil {
                print("User created!")
                //self.performSegue(withIdentifier: "accountCreated", sender: self)
                
                // 1. Upload the profile image to Firebase Storage
                
                self.uploadProfileImage(image) { url in
                    
                    if url != nil {
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.photoURL = url
                        
                        changeRequest?.commitChanges { error in
                            if error == nil {
                                print("User display name changed!")
                                
                                self.saveProfile(username: username, profileImageURL: url!) { success in
                                    if success {
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                                
                            } else {
                                print("Error: \(error!.localizedDescription)")
                            }
                        }
                    } else {
                        // Error unable to upload profile image
                    }
                    
                }
                
            } else {
                print("Error: \(error!.localizedDescription)")
            }
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
        
        func saveProfile(username:String, profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let databaseRef = Database.database().reference().child("users/profile/\(uid)")
            
            
            
            let test: [String: Any] = ["Book Title": username, "Book Author": username]
            
            
            let userObject = [
                "username": username,
                "photoURL": profileImageURL.absoluteString,
                "phoneNumber": phoneNumberTextField.text ?? "No phone number provided",
                "timestamp": [".sv":"timestamp"],
                "User's Listings": [

                    //["Book Title": "listingTitle", "Book Author": "listingAuthor"],
                    //["Book Title2": "listingTitle2", "Book Author2": "listingAuthor2"],
                    //test
                ],
                "Wish list items": [
                    //["bookTitle": "","bookAuthor": ""]
                ]
            ] as [String:Any]
            
            databaseRef.setValue(userObject) { error, ref in
                completion(error == nil)
            }
        }

    
    
    func setupUI(){
        
        fullNameTextField.layer.borderWidth = 2
        fullNameTextField.layer.cornerRadius = 10
        fullNameTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        fullNameTextField.layer.cornerRadius = 22
        fullNameTextField.clipsToBounds = true
        
        usernameTextField.layer.borderWidth = 2
        usernameTextField.layer.cornerRadius = 10
        usernameTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        usernameTextField.layer.cornerRadius = 22
        usernameTextField.clipsToBounds = true
        
        phoneNumberTextField.layer.borderWidth = 2
        phoneNumberTextField.layer.cornerRadius = 10
        phoneNumberTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        phoneNumberTextField.layer.cornerRadius = 22
        phoneNumberTextField.clipsToBounds = true
        
        
        
        emailTextField.layer.borderWidth = 2
        emailTextField.layer.cornerRadius = 10
        emailTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        emailTextField.layer.cornerRadius = 22
        emailTextField.clipsToBounds = true
        
        passwordTextField.layer.borderWidth = 2
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        passwordTextField.layer.cornerRadius = 22
        passwordTextField.clipsToBounds = true
        
        createAccountButton.layer.cornerRadius = 22
        
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


