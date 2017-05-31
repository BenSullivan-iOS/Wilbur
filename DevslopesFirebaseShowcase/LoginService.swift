//
//  LoginService.swift
//  Wilbur
//
//  Created by Ben Sullivan on 19/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import Firebase

protocol LoginServiceDelegate: class {
  
  func loginSuccessful()
  func loginFailed()
  
}

struct LoginService: HelperFunctions {
  
  weak var delegate: LoginServiceDelegate? = nil
    
  func didSignIn(_ signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError?) {
    
    guard error == nil else {
      
      self.delegate?.loginFailed()
      print(error)
      
      return
    
    }
    
    let authentication = user.authentication
    let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                                 accessToken: (authentication?.accessToken)!)
    
    FIRAuth.auth()?.signIn(with: credential) { user, error in
      
      print(user)
      
      guard let user = user, error == nil else {
        
        self.delegate?.loginFailed()
        print(error)
        
        return
      }
      
      UserDefaults.standard.setValue(user.displayName, forKey: "username")
      UserDefaults.standard.setValue(user.uid, forKey: Constants.KEY_UID)
      
      let userRef = DataService.ds.REF_USER_CURRENT.child("username")
      userRef.setValue(user.displayName)
      
      if let imageURL = user.photoURL {
        
        let url = String(describing: imageURL)
        let firebaseRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(user.uid)
        
        firebaseRef.setValue(url)
        
        guard let downloadImage = try? Data(contentsOf: imageURL) else {
          
          Cache.shared.profileImageCache.setObject(#imageLiteral(resourceName: "profile-placeholder"), forKey: user.uid as AnyObject)
          
          self.delegate?.loginSuccessful()

          return
        }
        
        if let image = UIImage(data: downloadImage) {
          
          Cache.shared.profileImageCache.setObject(image, forKey: user.uid as AnyObject)
          
          ProfileImageTracker.imageLocations.insert(user.uid)
          
          print(image)
          print(user.uid)
          print(url)
          
        }
        
      }
      
        
        self.delegate?.loginSuccessful()
      
    }
      
    
  }

  
  func uploadImage(_ url: URL, uid: String) {
    
    guard let downloadImage = try? Data(contentsOf: url) else { return }
    
    let path = docsDirect() + "images/tempImage.jpg"

    try? downloadImage.write(to: URL(fileURLWithPath: path), options: [.atomic])
    
    let storageRef = FIRStorage.storage().reference()
    let profileImgRef = storageRef.child("profileImages/\(uid).jpg")
    
    let urlOfLocalImage = URL(fileURLWithPath: path)
    
    let task: FIRStorageUploadTask = profileImgRef.putFile(urlOfLocalImage, metadata: nil) { metadata, error in
      
//      guard let _ = metadata where error == nil else {
//        
//        print("error", error); return
//      
//      }
      
      print(error ?? "no error")
      
      DispatchQueue.main.async(execute: {
        
        if let image = UIImage(data: downloadImage) {
        
          Cache.shared.profileImageCache.setObject(image, forKey: uid as AnyObject)
        }
        
        let firebaseRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(uid)
        
        firebaseRef.setValue(firebaseRef.key)
      })
    }
    
    task.resume()
  
  }

  
}
