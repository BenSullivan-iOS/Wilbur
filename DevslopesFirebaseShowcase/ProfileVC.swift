//
//  ProfileVC.swift
//  Fart Club
//
//  Created by Ben Sullivan on 17/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

protocol ProfileTableDelegate {
  
  func rowSelected(rowTitle: SelectedRow)
}

enum SelectedRow {
  
  case MyPosts
  case PoppedPosts
  case Feedback
  case FeatureRequest
}

private class TempProfileImageStorage {
  
  static let shared = TempProfileImageStorage()
  
  var profileImage: UIImage? = nil
  
}

class ProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ProfileTableDelegate {
  
  @IBOutlet weak var profileImage: UIImageView!
  
  let imagePicker = UIImagePickerController()
  var selectedImagePath = NSURL?()
  
  @IBAction func setProfileImagePressed(sender: AnyObject) {
    
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      imagePickerAlert()
    } else {
      presentViewController(imagePicker, animated: true, completion: nil)
    }
  }
  func imagePickerAlert() {
    
    let alert = UIAlertController(title: "Where from??", message: "", preferredStyle: .ActionSheet)
    alert.popoverPresentationController?.sourceView = self.view
    
    alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
      
      print("camera")
      self.imagePicker.sourceType = .Camera
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    
    alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { action in
      
      print("photo library")
      
      self.imagePicker.sourceType = .PhotoLibrary
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Blow Off", style: .Cancel, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    print("did finish")
    let image = info[UIImagePickerControllerOriginalImage] as? UIImage
    profileImage.image = image
    
    let saveDirectory = String(HelperFunctions.getDocumentsDirectory()) + "/images/tempImage.jpg"
    
    let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    saveImage(tempImage, path: saveDirectory)
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  func saveImage (image: UIImage, path: String) -> Bool {
    
    let compressedImage = resizeImage(image, newWidth: 1536)
    let jpgImageData = UIImageJPEGRepresentation(compressedImage, 0)
    let result = jpgImageData!.writeToFile(String(path), atomically: true)
    
    selectedImagePath = NSURL(fileURLWithPath: path)
    
    saveProfileImageToFirebaseStorageWithURL(String(selectedImagePath))
    
    return result
  }
  
  func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  
  func saveProfileImageToFirebaseStorageWithURL(imagePath: String) {
    
    let currentUser = NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) as! String
    
    let firebaseRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(currentUser)

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
      
    }
  }
  
  @IBAction func popOffButtonPressed(sender: UIButton) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBOutlet weak var username: UILabel!
  
  func rowSelected(rowTitle: SelectedRow) {
    
    switch rowTitle {
    case .MyPosts:
      print("my posts")
    self.navigationController?.pushViewController(TopTrumpsVC(), animated: true) //FIXME: Why isn't this pusing as a nav controller?
    case .PoppedPosts:
      print("popped posts")
    case .Feedback:
      print("feedback")
    case .FeatureRequest:
      print("feature request")
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "embeddedTable" {
      print("embedded segue")
      
      let profileTable = segue.destinationViewController as? ProfileTable
      
      profileTable!.delegate = self
      
    }
  }
  
  var profileImageRef: FIRDatabaseReference!
  
  override func viewDidLoad() {
    
    if TempProfileImageStorage.shared.profileImage == nil {
      getProfileImageReferenceThenDownload()
    } else {
      profileImage.image = TempProfileImageStorage.shared.profileImage
    }
    
    
    imagePicker.delegate = self
    
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
    profileImage.clipsToBounds = true
    
    if let currentUsername = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
      
      username.text = currentUsername
    }
  }
  
  func getProfileImageReferenceThenDownload() {
    
    let currentUser = NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) as! String
    profileImageRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(currentUser)
    
    profileImageRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {
        
        print("profile vc = null found")
        
      } else {
        
        self.downloadProfileImage(snapshot.value as! String)
        
      }
      
    })
  }

  
  func downloadProfileImage(imageLocation: String) {
    
    print("Download Image")
    let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + imageLocation)
    
    let storageRef = FIRStorage.storage().reference()
    let pathReference = storageRef.child("profileImages").child(imageLocation + ".jpg")
    print("profile image path reference", pathReference)
    pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
      print("Write to file")
      guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
      
      print("SUCCESS - ")
      print(URL)
      print(saveLocation)
      
      let image = UIImage(data: NSData(contentsOfURL: URL)!)!
      
      self.profileImage.image = image
      TempProfileImageStorage.shared.profileImage = image
    }
  }

  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}
