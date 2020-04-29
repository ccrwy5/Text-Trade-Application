//
//  ProfilePageViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/23/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Firebase

class ProfilePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var listABookButton: UIButton!
    //@IBOutlet weak var updateInfoButton: UIButton!
    
    
    var listingReference: DatabaseReference!
    var bookmarkReference: DatabaseReference!
    var imagePicker: UIImagePickerController!

    
    var listingsList = [Listing]()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCurrentProfileInfo()
        populateListings()
        
        // Update functionality is below
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        setupUI()
        
    }
    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
      }
    
    @IBAction func listABookButtonPressed(_ sender: Any) {
    }
    
 //   @IBAction func updateButtonPressed(_ sender: Any) {
        
//        guard let image = profileImageView.image else { return }
//        self.updateProfile(image) { url in
//            if url != nil {
//                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
//                changeRequest?.photoURL = url
//                changeRequest?.commitChanges { error in
//                    if error == nil {
//                        self.saveProfile(profileImageURL: url!) { success in
//                            if success {
//                                self.dismiss(animated: true, completion: nil)
//                            }
//                        }
//
//                    } else {
//                        print("Error: \(error!.localizedDescription)")
//                    }
//                }
//            } else {
//                // Error unable to upload profile image
//            }
//
//        }
//        print("Photo Updated")
//   }
    
    
    func setupUI(){
        listABookButton.layer.cornerRadius = 10.0
        //updateInfoButton.layer.cornerRadius = 10.0
        listTableView.separatorColor = UIColor.gray
        listTableView.separatorStyle = .singleLine
    }
    
    func loadCurrentProfileInfo(){
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        let currentUserImage = Auth.auth().currentUser?.photoURL
        self.profileImageView.load(url: currentUserImage!)
        
        //let currentUser = UserPr
        //fullNameLabel.text =
        usernameLabel.text = Auth.auth().currentUser?.displayName
    }
    
    func populateListings(){
        let currentUser = (Auth.auth().currentUser?.uid)!
        listingReference = Database.database().reference().child("users").child("profile").child(currentUser).child("User's Listings")
        
        listingReference.observe(.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                self.listingsList.removeAll()
                
                for listing in snapshot.children.allObjects as! [DataSnapshot] {
                    let listingObject = listing.value as? [String:AnyObject]
                    let title = listingObject?["bookTitle"]
                    let author = listingObject?["bookAuthor"]
                    let id = listingObject?["id"]
                    let price = listingObject?["price"]
                    
                    let artist = Listing(id: id as! String?, bookTitle: title as! String?, bookAuthor: author as! String?, price: price as! String?)
                    
                    self.listingsList.append(artist)
                }
                self.listTableView.reloadData()
            }
        })
    }

    
    /* -------- Table View Functions -------- */
    
    // Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numberOfRows: Int = listingsList.count
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // Populate Cells from Arrays
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = listTableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfilePageTableViewCell
        
        let listing: Listing
        listing = listingsList[indexPath.row]
        cell.titleLabel.text = listing.bookTitle
        //cell.authorLabel.text = listing.bookAuthor
        cell.priceLabel.text = "$\(listing.price ?? "price")"
        
        return cell
    }

    // Header Title
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        
//        return "Swipe to manage your listings"
//    }
    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        view.tintColor = UIColor(red:255, green:153, blue:0, alpha: 1)
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.textColor = UIColor.white
//        //241, 184, 45
//    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        if segmentedControl.selectedSegmentIndex == 0 {
//            let currentUser = Auth.auth().currentUser?.displayName
//            let postDetailsVC = storyboard?.instantiateViewController(identifier: "PostDetailsViewController") as? PostDetailsViewController
//            //let post = posts[indexPath.row]
//            let listing = listingsList[indexPath.row]
//            postDetailsVC?.bookTitle = listing.bookTitle!
//            postDetailsVC?.authorName = listing.bookAuthor!
//            postDetailsVC?.sellerName = currentUser!
//            self.navigationController?.pushViewController(postDetailsVC!, animated: true)
//
//
//
//        } else if segmentedControl.selectedSegmentIndex == 1 {
//
//        }
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let currentUser = (Auth.auth().currentUser?.uid)!
        let selectedListing = self.listingsList[indexPath.row]
        
        let deleteSwipe = UIContextualAction(style: .destructive, title: "Delete/Mark as Sold") {  (contextualAction, view, boolValue) in

            let localDeleteRef = Database.database().reference().child("users").child("profile").child(currentUser).child("User's Listings")
            let indivListing = localDeleteRef.child(selectedListing.id!)
            
            var mainID: String = ""
            indivListing.observeSingleEvent(of: .value) { (snapshot) in
                let dict = snapshot.value as! [String: Any]
                mainID = dict["mainID"] as! String
                print("MainID: \(mainID)")
                let feedDeleteRef = Database.database().reference().child("posts").child(mainID)
                print("feedDeleteRef = \(feedDeleteRef)")
                            
                
                self.listingsList.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
                
                
                indivListing.setValue(nil)
                feedDeleteRef.setValue(nil)

            }
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteSwipe])
        return swipeActions
    }
  
//    /* Update Photo */
//    func updateProfile(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let storageRef = Storage.storage().reference().child("user/\(uid)")
//
//        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
//
//        let metaData = StorageMetadata()
//        metaData.contentType = "image/jpg"
//
//        storageRef.putData(imageData, metadata: metaData) { metaData, error in
//        if error == nil, metaData != nil {
//
//        storageRef.downloadURL { url, error in
//            completion(url)
//            // success!
//            }
//        } else {
//            // failed
//            completion(nil)
//            }
//        }
//
//    }
//
//    func saveProfile(profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let databaseRef = Database.database().reference().child("users/profile/\(uid)")
//
//        let userObject = [
//            "photoURL": profileImageURL.absoluteString,
//        ] as [String:Any]
//
//        databaseRef.updateChildValues(userObject) { (error, ref) in
//            completion(error == nil)
//        }
//    }
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

extension ProfilePageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
