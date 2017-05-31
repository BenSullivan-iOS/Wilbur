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
  
  func downloadImage(_ imageLocation: String) {
    
    let saveLocation = URL(fileURLWithPath: docsDirect() +  imageLocation)
    
    let storageRef: FIRStorageReference? = FIRStorage.storage().reference()
    
    guard let storage = storageRef else { return }
    
    let pathReference = storage.child(imageLocation)
    
    downloadImageTask = pathReference.write(toFile: saveLocation) { URL, error -> Void in
      
      guard let URL = URL, error == nil else { print("Download Image Error", error.debugDescription); return }
      
      if let data = try? Data(contentsOf: URL) {
        
        if let image = UIImage(data: data) {
          
          let newImage = self.resizeImage(image, newWidth: 414)
          
          DispatchQueue.main.async(execute: {

          self.showcaseImg.clipsToBounds = true
          self.showcaseImg.image = newImage
          self.showcaseImg.isHidden = false
          })
          
          Cache.shared.imageCache.setObject(newImage, forKey: imageLocation as AnyObject)
          
//          self.reloadTableDelegate?.reloadTable()
          print("FIX ME RELOAD DATA")
          
        }
      }
    }
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
      
      Cache.shared.profileImageCache.setObject(image, forKey: uid as AnyObject)
      
      ProfileImageTracker.imageLocations.insert(uid)
      
      DispatchQueue.main.async(execute: {

        self.profileImg.image = image
      })
      
    })
  }
  
  func downloadProfileImageFromStorage(_ uid: String) {
    
    if !ProfileImageTracker.imageLocations.contains(uid) {
      
      let saveLocation = URL(fileURLWithPath: docsDirect() +  uid)
      let storageRef = FIRStorage.storage().reference()
      let pathReference = storageRef.child("profileImages").child(uid + ".jpg")
      
      self.downloadProfileImageTask = pathReference.write(toFile: saveLocation) { URL, error -> Void in
        
        guard let URL = URL, error == nil else {
          print("Error - Missing profile pic")
          
          Cache.shared.profileImageCache.setObject(UIImage(named: "profile-placeholder")!, forKey: (uid as AnyObject))
          self.profileImg.image = UIImage(named: "profile-placeholder")
          
          return
        }
        
        if let data = try? Data(contentsOf: URL) {
          
          if let image = UIImage(data: data) {
            
            Cache.shared.profileImageCache.setObject(image, forKey: (uid as AnyObject))
            ProfileImageTracker.imageLocations.insert(uid)
            print("UID = ", uid)
            
            if self.profileImg.image == UIImage(named: "profile-placeholder") {
              
              let newImage = self.resizeImage(image, newWidth: 100)
              self.profileImg.image = newImage
              
              Cache.shared.profileImageCache.setObject(newImage, forKey: uid as AnyObject)
              
            }
          }
        }
      }
    } else {
      print("Post Cell, profile image already chached")
    }
  }
  
}
