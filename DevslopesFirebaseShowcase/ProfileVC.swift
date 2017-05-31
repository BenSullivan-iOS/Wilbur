//
//  ProfileVC.swift
//  Wilbur
//
//  Created by Ben Sullivan on 17/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

enum SelectedRow {
  
  case myPosts
  case poppedPosts
  case feedback
  case featureRequest
}

class ProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, HelperFunctions {
  
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var profileImage: UIImageView!
  
  fileprivate let imagePicker = UIImagePickerController()
  fileprivate var profileImageRef: FIRDatabaseReference!
  fileprivate var selectedImagePath: URL?
  fileprivate var loggedIn = true
  
  //MARK: - VC LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let userKey = DataService.ds.currentUserKey {

      if let image = Cache.shared.profileImageCache.object(forKey: userKey as AnyObject) as? UIImage {
        
        profileImage.image = image
        
      } else {
        
        getProfileImageReferenceThenDownload()
      }
      
    } else {
      
      getProfileImageReferenceThenDownload()
    }
    
    imagePicker.delegate = self
    
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
    profileImage.clipsToBounds = true
    
    if let currentUsername = UserDefaults.standard.value(forKey: "username") as? String {
      
      username.text = currentUsername
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
    if !loggedIn {
      guestAlert()
    }

  }
  
  //MARK: - BUTTONS
  
  @IBAction func setProfileImagePressed(_ sender: AnyObject) {
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
//      self.imagePicker.sourceType = .Camera
//      self.imagePicker.cameraDevice = .Front
//      presentViewController(imagePicker, animated: true, completion: nil)

      imagePickerAlert()
    } else {
      present(imagePicker, animated: true, completion: nil)
    }
  }
  
  @IBAction func backButtonPressed(_ sender: UIButton) {
    
    dismiss(animated: true, completion: nil)
  }
  
  //MARK: - IMAGE FUNCTIONS
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    profileImage.image = image
    
    let saveDirectory = docsDirect() + "images/tempImage.jpg"
    print("Did finish save directory = ", saveDirectory)
    
    saveImage(image, path: saveDirectory)
    
    dismiss(animated: true, completion: nil)
  }
  
  
  func saveImage(_ image: UIImage, path: String) -> Bool {
    
    let compressedImage = resizeImage(image, newWidth: 280)
    if let jpgImageData = UIImageJPEGRepresentation(compressedImage, 0.5) {
      let result = (try? jpgImageData.write(to: URL(fileURLWithPath: String(path)), options: [.atomic])) != nil
      
      selectedImagePath = URL(fileURLWithPath: path)
      saveProfileImageToFirebaseStorageWithURL(String(describing: selectedImagePath))
      
      return result
    }
    
    return false
  }
  
  func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  
  func saveProfileImageToFirebaseStorageWithURL(_ imagePath: String) {
    
    let firebaseRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(DataService.ds.currentUserKey!)
    
    if let imagePath = selectedImagePath {
      
      uploadImage(imagePath, firebaseReference: firebaseRef.key)
    }
    
    firebaseRef.setValue(firebaseRef.key)
  }
  
  func uploadImage(_ localFile: URL, firebaseReference: String) {
    
    let storageRef = FIRStorage.storage().reference()
    let riversRef = storageRef.child("profileImages/\(firebaseReference).jpg")
    
    riversRef.putFile(localFile, metadata: nil) { metadata, error in
      
      guard let metadata = metadata, error == nil else { print("error", error); return }
      

      DispatchQueue.main.async(execute: { 
        
        Cache.shared.profileImageCache.removeAllObjects()
      })
    }
  }
  
  func getProfileImageReferenceThenDownload() {
    
    
    if let currentUser = DataService.ds.currentUserKey {
            
      profileImageRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(currentUser)
      
      profileImageRef.observeSingleEvent(of: .value, with: { snapshot in
        
        if let _ = snapshot.value as? NSNull {
          
          print("profile vc = null found")
          
        } else {
          
          self.downloadProfileImage(snapshot.value as! String)
          
        }
        
      })
      
    } else {
      loggedIn = false
    }
  }

  func downloadProfileImage(_ imageLocation: String) {
    
    let saveLocation = URL(fileURLWithPath: docsDirect() + "/\(imageLocation)")
    let storageRef = FIRStorage.storage().reference()
    let pathReference = storageRef.child("profileImages").child(imageLocation + ".jpg")

    pathReference.write(toFile: saveLocation) { (URL, error) -> Void in

      guard let URL = URL, error == nil else { print("Error - ", error.debugDescription); return }
      
      print("SUCCESS - ")
      print(URL)
      print(saveLocation)
      
      guard let data = try? Data(contentsOf: URL), let image = UIImage(data: data) else { return }
      
      self.profileImage.image = image
      
      Cache.shared.profileImageCache.setObject(image, forKey: DataService.ds.currentUserKey! as AnyObject)
    }
  }
  
  //MARK: - AlERTS
  
  func guestAlert() {
    
    let alert = UIAlertController(title: "Function unavailable", message: "You must be logged in to access your profile", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { action in
      
      AppState.shared.currentState = .presentLoginFromComments
      
      self.dismiss(animated: false, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
      
      self.dismiss(animated: true, completion: nil)
      
    }))
    
    self.present(alert, animated: true, completion: nil)
  }

  
  func imagePickerAlert() {
    
    let alert = UIAlertController(title: "Where from??", message: "", preferredStyle: .actionSheet)
    alert.popoverPresentationController?.sourceView = self.view
    
    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
      
      print("camera")
      self.imagePicker.sourceType = .camera
      self.imagePicker.cameraDevice = .front
      
      self.present(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
      
      print("photo library")
      
      self.imagePicker.sourceType = .photoLibrary
      self.present(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(alert, animated: true, completion: nil)
  }
  
  //MARK: - OTHER
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
}
