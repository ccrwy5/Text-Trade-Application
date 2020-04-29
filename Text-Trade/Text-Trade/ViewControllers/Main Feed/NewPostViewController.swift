//
//  NewPostViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/20/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Foundation
import Firebase

//protocol NewPostVCDelegate {
//    func didUploadPost(withID id: String)
//}

class NewPostViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var classUsedForTextField: UITextField!
    @IBOutlet weak var askingPriceTextField: UITextField!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var QRButtonText: UIButton!
    //@IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var bookCoverTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var conditionSegmentedControl: UISegmentedControl!
    
    //var delegate: NewPostVCDelegate?
    
    var verificationId = String()
    var imagePicker: UIImagePickerController!
    let postRef = Database.database().reference().child("posts").childByAutoId()
    //let currentUser = (Auth.auth().currentUser?.uid)!
    let listingDatabaseRef = Database.database().reference().child("users").child("profile").child((Auth.auth().currentUser?.uid)!).child("User's Listings").childByAutoId()
    var bookImage: UIImage? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let testString = verificationId

        let array = testString.components(separatedBy: "by ")
        //print(array)
        let title = array.first!
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        let author = array.last!
        
        titleTextField.text = trimmedTitle
        authorTextField.text = author
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        setupUI()
        conditionSegmentedControl.selectedSegmentTintColor = UIColor.systemGreen

        
        titleTextField.delegate = self
        authorTextField.delegate = self
        classUsedForTextField.delegate = self
        askingPriceTextField.delegate = self
        
        postButton.isEnabled = false
        
        [titleTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        [authorTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        [askingPriceTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        [classUsedForTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
                
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        bookImageView.isUserInteractionEnabled = true
        bookImageView.addGestureRecognizer(imageTap)
        bookImageView.layer.cornerRadius = bookImageView.bounds.height / 2
        bookImageView.clipsToBounds = true

    }
    
    func setupUI(){
        titleTextField.layer.borderWidth = 2
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        titleTextField.layer.cornerRadius = 12
        titleTextField.clipsToBounds = true
        
        authorTextField.layer.borderWidth = 2
        authorTextField.layer.cornerRadius = 10
        authorTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        authorTextField.layer.cornerRadius = 12
        authorTextField.clipsToBounds = true
        
        classUsedForTextField.layer.borderWidth = 2
        classUsedForTextField.layer.cornerRadius = 10
        classUsedForTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        classUsedForTextField.layer.cornerRadius = 12
        classUsedForTextField.clipsToBounds = true
        
        askingPriceTextField.layer.borderWidth = 2
        askingPriceTextField.layer.cornerRadius = 10
        askingPriceTextField.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        askingPriceTextField.layer.cornerRadius = 12
        askingPriceTextField.clipsToBounds = true
        
        bookImageView.layer.cornerRadius = bookImageView.bounds.height / 2
        bookImageView.clipsToBounds = true
        
        QRButtonText.titleLabel?.adjustsFontSizeToFitWidth = true
        //cameraButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        askingPriceTextField.delegate = self
        
        
    }
    
    
    @IBAction func conditionChanged(_ sender: Any) {
        if(conditionSegmentedControl.selectedSegmentIndex == 0) {
            conditionSegmentedControl.selectedSegmentTintColor = UIColor.systemGreen
        } else if(conditionSegmentedControl.selectedSegmentIndex == 1) {
            conditionSegmentedControl.selectedSegmentTintColor = UIColor.systemTeal
        } else if(conditionSegmentedControl.selectedSegmentIndex == 2) {
            conditionSegmentedControl.selectedSegmentTintColor = UIColor.systemOrange
        }
        if(conditionSegmentedControl.selectedSegmentIndex == 3) {
            conditionSegmentedControl.selectedSegmentTintColor = UIColor.systemRed
        }
    }
    
    
    func getCondition() -> String {
        var condition = ""
        if(conditionSegmentedControl.selectedSegmentIndex == 0){
            condition = "New"
        } else if(conditionSegmentedControl.selectedSegmentIndex == 1){
            condition = "Good"
        } else if(conditionSegmentedControl.selectedSegmentIndex == 2){
            condition = "Fair"
        } else if(conditionSegmentedControl.selectedSegmentIndex == 3){
            condition = "Poor"
        }
        
        return condition
    }
    
    
    @IBAction func handlePostButton(_ sender: Any) {
        
        
        guard let userProfile = UserService.currentUserProfile else {
            print("error in userProfile")
            return
            
        }
        guard let imageSelected = self.bookImage else {
            
            let alertController = UIAlertController(title: "Unable to post", message: "Must add photo of book", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
            print("image is nil")
            return
        }
        
        var bookCoverType = ""
        if(bookCoverTypeSegmentedControl.selectedSegmentIndex == 0){
            bookCoverType = "Hardcover"
        } else {
            bookCoverType = "Paperback"
        }
        
        let condition = getCondition()
        
        
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
            return
        }

        /* Set's the book into the posts section of DB */
        //let postRef = Database.database().reference().child("posts").childByAutoId()
        var postObject = [
            "author": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString,
                "phoneNumber": userProfile.phoneNumber,
                "email": userProfile.email,
                "fullName": userProfile.fullName
            ],
            "bookTitle": titleTextField.text ?? "",
            "bookAuthor": authorTextField.text ?? "",
            "classUsedFor": classUsedForTextField.text ?? "",
            "price": askingPriceTextField.text ?? "",
            "timestamp": [".sv":"timestamp"],
            "postID": postRef.key!,
            "bookCoverType": bookCoverType,
            "bookCondition": condition,
            //"bookImageURL": "url",
            "peopleWhoLike": [""]
        ] as [String:Any]
        print("3")
        
        let storageRef = Storage.storage().reference().child("posts/\(postRef.key!)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metadata) { (storageMetaData, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
                return
            }
            storageRef.downloadURL { (url, error) in
                if let metaImageUrl = url?.absoluteString {
                    print(metaImageUrl)
                    postObject["bookImageURL"] = metaImageUrl
                    
                    self.postRef.updateChildValues(postObject) { (erro, ref) in
                        if error == nil {
                            print("done")
                        }
                    }

                }
            }
        }

        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                
                self.navigationController?.popViewController(animated: true)
                //self.delegate?.didUploadPost(withID: ref.key!)
                self.dismiss(animated: true, completion: nil)
            } else {
                print("error in postRef setValue")
            }
        })
        
        print("4")

        
        /* Set's the book into the user's listings section of DB */
        
        //let currentUser = (Auth.auth().currentUser?.uid)!
        
        //let listingDatabaseRef = Database.database().reference().child("users").child("profile").child(currentUser).child("User's Listings").childByAutoId()
        let listingObject = [
            "id": listingDatabaseRef.key!,
            "mainID": postRef.key!,
            "bookTitle": titleTextField.text ?? "",
            "bookAuthor": authorTextField.text ?? "",
            "price": askingPriceTextField.text ?? "",
            "bookCondition": condition,
            "bookCoverType": bookCoverType
        ] as [String: Any]
        
        //listingDatabaseRef.setValue(listingObject)
        listingDatabaseRef.updateChildValues(listingObject) { (error, ref) in
            if error == nil{
                print("done 2")
            }
        }

    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == titleTextField {
            return range.location < 30
        } else if textField == authorTextField {
            return range.location < 20
        } else if textField == classUsedForTextField {
            return range.location < 20
        } else if textField == askingPriceTextField {
            
            return range.location < 8
        }
        
        
        return range.location < 20
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == askingPriceTextField{
            //askingPriceTextField.text = "$"
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        //textView.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            super.dismiss(animated: flag, completion: completion)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //textView.becomeFirstResponder()
        
    }
    

    
    @objc func openImagePicker(){
        print("image pressed")
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func uploadPhoto(){
        let storageRef = Storage.storage().reference().child("posts/\(postRef.key!)")
        if let uploadData = bookImageView.image!.pngData() {
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error)
                    return
                }
                
                //print(metadata)
            })
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
            guard let title = titleTextField.text, !title.isEmpty
            else {
                self.postButton.isEnabled = false
                return
            }
            postButton.isEnabled = true
        
            guard let author = authorTextField.text, !author.isEmpty
            else {
                self.postButton.isEnabled = false
                return
            }
            postButton.isEnabled = true
        
            guard let classUsedFor = classUsedForTextField.text, !classUsedFor.isEmpty
            else {
                self.postButton.isEnabled = false
                return
            }
            postButton.isEnabled = true
        
            guard let price = askingPriceTextField.text, !price.isEmpty
            else {
                self.postButton.isEnabled = false
                return
            }
            postButton.isEnabled = true
           

    }
    
    
    
    @IBAction func QRButtonTextPressed(_ sender: Any) {
    }
    

    
   
    
    
    


          
}

extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            bookImage = pickedImage
            self.bookImageView.image = pickedImage
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

