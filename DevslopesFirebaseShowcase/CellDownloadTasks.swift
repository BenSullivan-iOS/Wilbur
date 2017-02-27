//
//  CellDownloadTasks.swift
//  Wildlife
//
//  Created by Ben Sullivan on 05/08/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

extension CellConfiguration {
  
  func downloadImage(imageLocation: String) {
    
    let saveLocation = NSURL(fileURLWithPath: docsDirect() +  imageLocation)
    
    let storageRef: FIRStorageReference? = FIRStorage.storage().reference()
    
    guard let storage = storageRef else { return }
    
    let pathReference = storage.child(imageLocation)
    
    downloadImageTask = pathReference.writeToFile(saveLocation) { URL, error -> Void in
      
      guard let URL = URL where error == nil else { print("Download Image Error", error.debugDescription); return }
      
      if let data = NSData(contentsOfURL: URL) {
        
        if let image = UIImage(data: data) {
          
          let newImage = self.resizeImage(image, newWidth: 414)
          
          dispatch_async(dispatch_get_main_queue(), {

          self.showcaseImg.clipsToBounds = true
          self.showcaseImg.image = newImage
          self.showcaseImg.hidden = false
          })
          
          Cache.shared.imageCache.setObject(newImage, forKey: imageLocation)
          
//          self.reloadTableDelegate?.reloadTable()
          print("FIX ME RELOAD DATA")
          
        }
      }
    }
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
      
      dispatch_async(dispatch_get_main_queue(), {

        self.profileImg.image = image
      })
      
    })
  }
  
  func downloadProfileImageFromStorage(uid: String) {
    
    if !ProfileImageTracker.imageLocations.contains(uid) {
      
      let saveLocation = NSURL(fileURLWithPath: docsDirect() +  uid)
      let storageRef = FIRStorage.storage().reference()
      let pathReference = storageRef.child("profileImages").child(uid + ".jpg")
      
      self.downloadProfileImageTask = pathReference.writeToFile(saveLocation) { URL, error -> Void in
        
        guard let URL = URL where error == nil else { print("Error - ", error.debugDescription);
          
          Cache.shared.profileImageCache.setObject(UIImage(named: "profile-placeholder")!, forKey: (uid))
          
          return }
        
        if let data = NSData(contentsOfURL: URL) {
          
          if let image = UIImage(data: data) {
            
            Cache.shared.profileImageCache.setObject(image, forKey: (uid))
            ProfileImageTracker.imageLocations.insert(uid)
            
            if self.profileImg.image == UIImage(named: "profile-placeholder") {
              
              let newImage = self.resizeImage(image, newWidth: 100)
              self.profileImg.image = newImage
              
              Cache.shared.profileImageCache.setObject(newImage, forKey: uid)
              
            }
          }
        }
      }
    } else {
      print("Post Cell, profile image already chached")
    }
  }
  
}
