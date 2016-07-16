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
    
    if let value = Cache.FeedVC.profileImageCache.objectForKey(value) as? UIImage {
      
      profileImage.image = value
    } else {
      downloadProfileImage(value)
    }
  }
  
  func downloadProfileImage(userKey: String) {
    
    if !ProfileImageTracker.imageLocations.contains(userKey) {
      
      let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + userKey)
      let storageRef = FIRStorage.storage().reference()
      let pathReference = storageRef.child("profileImages").child(userKey + ".jpg")
      
       pathReference.writeToFile(saveLocation) { URL, error -> Void in
        
        guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
        
        if let data = NSData(contentsOfURL: URL) {
          
          if let image = UIImage(data: data) {
            
            Cache.FeedVC.profileImageCache.setObject(image, forKey: (userKey))
            ProfileImageTracker.imageLocations.insert(userKey)
            
            self.profileImage.image = image
            
          }
        }
      }
    } else {
      print("Post Cell, profile image already chached")
    }
  }

}
