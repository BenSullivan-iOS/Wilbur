//
//  CommentCell.swift
//  Wilbur
//
//  Created by Ben Sullivan on 03/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import FirebaseStorage

class CommentCell: UITableViewCell, HelperFunctions {
  
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var commentText: UITextView!
  @IBOutlet weak var username: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    profileImage.layer.cornerRadius = profileImage.frame.width / 2
    profileImage.clipsToBounds = true
    commentText.isSelectable = false
  }
  
  func configureCell(_ key: String, value: String, user: String) {
        
    profileImage.image = UIImage(named: "profile-placeholder")
    
    username.text = user
    commentText.text = key
    
    if let value = Cache.shared.profileImageCache.object(forKey: value as AnyObject) as? UIImage {
      
      profileImage.image = value
    } else {
      downloadProfileImage(value)
    }
  }
  
  func downloadProfileImage(_ uid: String) {
    
    let profileImgRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(uid)
    
    profileImgRef.observeSingleEvent(of: .value, with: { snap in
      
      guard let value = snap.value else { return }
      
      let stringURL = String(describing: value)
      
      print("snap", value)
      print(stringURL)
      
      guard let url = URL(string: stringURL) else {
        self.downloadProfileImageFromStorage(uid)
        
        return }
      
      guard let downloadImage = try? Data(contentsOf: url) else {
        self.downloadProfileImageFromStorage(uid)
        
        return }
      
      guard let image = UIImage(data: downloadImage) else {
        self.downloadProfileImageFromStorage(uid)
        
        return }
      
      print(image)
      
      Cache.shared.profileImageCache.setObject(image, forKey: uid as AnyObject)
      
      ProfileImageTracker.imageLocations.insert(uid)
      
      self.profileImage.image = image
      
    })
    
    
  }
  
  func downloadProfileImageFromStorage(_ uid: String) {
    
    if !ProfileImageTracker.imageLocations.contains(uid) {
      
      let saveLocation = URL(fileURLWithPath: docsDirect() +  uid)
      let storageRef = FIRStorage.storage().reference()
      let pathReference = storageRef.child("profileImages").child(uid + ".jpg")
      
      pathReference.write(toFile: saveLocation) { URL, error -> Void in
        
        guard let URL = URL, error == nil else {
          
          print("Error - Profile image not found")
          
          Cache.shared.profileImageCache.setObject(UIImage(named: "profile-placeholder")!, forKey: (uid as AnyObject))
          
          DispatchQueue.main.async(execute: {
            
            self.profileImage.image = UIImage(named: "profile-placeholder")
          })

          return }
        
        if let data = try? Data(contentsOf: URL) {
          
          if let image = UIImage(data: data) {
            
            Cache.shared.profileImageCache.setObject(image, forKey: (uid as AnyObject))
            ProfileImageTracker.imageLocations.insert(uid)
            
            if self.profileImage.image == UIImage(named: "profile-placeholder") {
              
              DispatchQueue.main.async(execute: { 
                
                self.profileImage.image = image

              })
            }
          }
        }
      }
    } else {
      print("Post Cell, profile image already chached")
    }
  }
}
