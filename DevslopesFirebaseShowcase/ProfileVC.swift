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
  
  case MyPosts
  case PoppedPosts
  case Feedback
  case FeatureRequest
}

class ProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var profileImage: UIImageView!
  
  private let imagePicker = UIImagePickerController()
  private var profileImageRef: FIRDatabaseReference!
  private var selectedImagePath = NSURL?()
  private var loggedIn = true
  
  //MARK: - VC LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let userKey = DataService.ds.currentUserKey {

      if let image = Cache.shared.profileImageCache.objectForKey(userKey) as? UIImage {
        
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
    
    if let currentUsername = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
      
      username.text = currentUsername
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    
    if !loggedIn {
      guestAlert()
    }

  }
  
  //MARK: - BUTTONS
  
  @IBAction func setProfileImagePressed(sender: AnyObject) {
    
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
//      self.imagePicker.sourceType = .Camera
//      self.imagePicker.cameraDevice = .Front
//      presentViewController(imagePicker, animated: true, completion: nil)

      imagePickerAlert()
    } else {
      presentViewController(imagePicker, animated: true, completion: nil)
    }
  }
  
  @IBAction func backButtonPressed(sender: UIButton) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK: - IMAGE FUNCTIONS
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    profileImage.image = image
    
    let saveDirectory = direct().stringByAppendingPathComponent("/images/tempImage.jpg")
    print("Did finish save directory = ", saveDirectory)
    
    saveImage(image, path: saveDirectory)
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  func saveImage(image: UIImage, path: String) -> Bool {
    
    let compressedImage = resizeImage(image, newWidth: 280)
    if let jpgImageData = UIImageJPEGRepresentation(compressedImage, 0.5) {
      let result = jpgImageData.writeToFile(String(path), atomically: true)
      
      selectedImagePath = NSURL(fileURLWithPath: path)
      saveProfileImageToFirebaseStorageWithURL(String(selectedImagePath))
      
      return result
    }
    
    return false
  }
  
  func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  func saveProfileImageToFirebaseStorageWithURL(imagePath: String) {
    
    let firebaseRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(DataService.ds.currentUserKey!)
    
    if let imagePath = selectedImagePath {
      
      uploadImage(imagePath, firebaseReference: firebaseRef.key)
    }
    
    firebaseRef.setValue(firebaseRef.key)
  }
  
  func uploadImage(localFile: NSURL, firebaseReference: String) {
    
    let storageRef = FIRStorage.storage().reference()
    let riversRef = storageRef.child("profileImages/\(firebaseReference).jpg")
    
    riversRef.putFile(localFile, metadata: nil) { metadata, error in
      
      guard let metadata = metadata where error == nil else { print("error", error); return }
      

      dispatch_async(dispatch_get_main_queue(), { 
        
        Cache.shared.profileImageCache.removeAllObjects()
      })
    }
  }
  
  func getProfileImageReferenceThenDownload() {
    
    
    if let currentUser = DataService.ds.currentUserKey {
            
      profileImageRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(currentUser)
      
      profileImageRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        
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

  func downloadProfileImage(imageLocation: String) {
    
    let saveLocation = NSURL(fileURLWithPath: direct().stringByAppendingPathComponent("/\(imageLocation)"))
    let storageRef = FIRStorage.storage().reference()
    let pathReference = storageRef.child("profileImages").child(imageLocation + ".jpg")

    pathReference.writeToFile(saveLocation) { (URL, error) -> Void in

      guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
      
      print("SUCCESS - ")
      print(URL)
      print(saveLocation)
      
      guard let data = NSData(contentsOfURL: URL), image = UIImage(data: data) else { return }
      
      self.profileImage.image = image
      
      Cache.shared.profileImageCache.setObject(image, forKey: DataService.ds.currentUserKey!)
    }
  }
  
  //MARK: - AlERTS
  
  func guestAlert() {
    
    let alert = UIAlertController(title: "Function unavailable", message: "You must be logged in to access your profile", preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Login", style: .Default, handler: { action in
      
      AppState.shared.currentState = .PresentLoginFromComments
      
      self.dismissViewControllerAnimated(false, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
      
      self.dismissViewControllerAnimated(true, completion: nil)
      
    }))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }

  
  func imagePickerAlert() {
    
    let alert = UIAlertController(title: "Where from??", message: "", preferredStyle: .ActionSheet)
    alert.popoverPresentationController?.sourceView = self.view
    
    alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
      
      print("camera")
      self.imagePicker.sourceType = .Camera
      self.imagePicker.cameraDevice = .Front
      
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { action in
      
      print("photo library")
      
      self.imagePicker.sourceType = .PhotoLibrary
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  //MARK: - OTHER
  
  func direct() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}
