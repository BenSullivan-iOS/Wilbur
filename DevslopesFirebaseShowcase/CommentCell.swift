//
//  CommentCell.swift
// Wilbur
//
//  Created by Ben Sullivan on 03/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import FirebaseStorage

class CommentCell: UITableViewCell {
  
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var commentText: UITextView!
  @IBOutlet weak var username: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    profileImage.layer.cornerRadius = profileImage.frame.width / 2
    profileImage.clipsToBounds = true
    commentText.selectable = false
  }
  
  func configureCell(key: String, value: String, user: String) {
        
    profileImage.image = UIImage(named: "profile-placeholder")
    
    username.text = user
    commentText.text = key
    
    if let value = Cache.shared.profileImageCache.objectForKey(value) as? UIImage {
      
      profileImage.image = value
    } else {
      downloadProfileImage(value)
    }
  }
  
  func downloadProfileImage(uid: String) {
    
    let profileImgRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(uid)
    
    profileImgRef.observeSingleEventOfType(.Value, withBlock: { snap in
      
      guard let value = snap.value else { return }
      
      let stringURL = String(value)
      
      print("snap", value)
      print(stringURL)
      
      guard let url = NSURL(string: stringURL) else {
        self.downloadProfileImageFromStorage(uid)
        
        return }
      
      guard let downloadImage = NSData(contentsOfURL: url) else {
        self.downloadProfileImageFromStorage(uid)
        
        return }
      
      guard let image = UIImage(data: downloadImage) else {
        self.downloadProfileImageFromStorage(uid)
        
        return }
      
      print(image)
      
      Cache.shared.profileImageCache.setObject(image, forKey: uid)
      
      ProfileImageTracker.imageLocations.insert(uid)
      
      self.profileImage.image = image
      
    })
    
    
  }
  
  func downloadProfileImageFromStorage(uid: String) {
    
    if !ProfileImageTracker.imageLocations.contains(uid) {
      
      let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + uid)
      let storageRef = FIRStorage.storage().reference()
      let pathReference = storageRef.child("profileImages").child(uid + ".jpg")
      
      pathReference.writeToFile(saveLocation) { URL, error -> Void in
        
        guard let URL = URL where error == nil else { print("Error - ", error.debugDescription);
          
          Cache.shared.profileImageCache.setObject(UIImage(named: "profile-placeholder")!, forKey: (uid))
          
          return }
        
        if let data = NSData(contentsOfURL: URL) {
          
          if let image = UIImage(data: data) {
            
            Cache.shared.profileImageCache.setObject(image, forKey: (uid))
            ProfileImageTracker.imageLocations.insert(uid)
            
            self.profileImage.image = image
          }
        }
      }
    } else {
      print("Post Cell, profile image already chached")
    }
  }
}
