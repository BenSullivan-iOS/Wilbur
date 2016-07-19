//
//  LoginService.swift
//  Wildlife
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

class LoginService {
  
  static let shared = LoginService()
  private init() {}
  
  weak var delegate: LoginServiceDelegate? = nil
  
  func didSignIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError?) {
    
    guard error == nil else {
      
      self.delegate?.loginFailed()
      print(error)
      
      return
    
    }
    
    let authentication = user.authentication
    let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                                 accessToken: authentication.accessToken)
    
    FIRAuth.auth()?.signInWithCredential(credential) { user, error in
      
      print(user)
      
      guard let user = user where error == nil else {
        
        self.delegate?.loginFailed()
        print(error)
        
        return
      }
      
      NSUserDefaults.standardUserDefaults().setValue(user.displayName, forKey: "username")
      NSUserDefaults.standardUserDefaults().setValue(user.uid, forKey: Constants.shared.KEY_UID)
      
      let userRef = DataService.ds.REF_USER_CURRENT.child("username")
      userRef.setValue(user.displayName)
      
      if let imageURL = user.photoURL {
        
        let url = String(imageURL)
        let firebaseRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(user.uid)
        
        firebaseRef.setValue(url)
        
        guard let downloadImage = NSData(contentsOfURL: imageURL) else { return }
        
        if let image = UIImage(data: downloadImage) {
          
          Cache.shared.profileImageCache.setObject(image, forKey: user.uid)
          
          ProfileImageTracker.imageLocations.insert(user.uid)
          
          print(image)
          print(user.uid)
          print(url)
          
        }
        
      }
      
        
        self.delegate?.loginSuccessful()
      
    }
      
    
  }
  
  func direct() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }

  
  func uploadImage(url: NSURL, uid: String) {
    
    guard let downloadImage = NSData(contentsOfURL: url) else { return }
    
    let path = direct().stringByAppendingPathComponent("images/tempImage.jpg")

    downloadImage.writeToFile(path, atomically: true)
    
    let storageRef = FIRStorage.storage().reference()
    let profileImgRef = storageRef.child("profileImages/\(uid).jpg")
    
    let urlOfLocalImage = NSURL(fileURLWithPath: path)
    
    let task: FIRStorageUploadTask = profileImgRef.putFile(urlOfLocalImage, metadata: nil) { metadata, error in
      
//      guard let _ = metadata where error == nil else {
//        
//        print("error", error); return
//      
//      }
      
      print(error ?? "no error")
      
      dispatch_async(dispatch_get_main_queue(), {
        
        if let image = UIImage(data: downloadImage) {
        
          Cache.shared.profileImageCache.setObject(image, forKey: uid)
        }
        
        let firebaseRef = DataService.ds.REF_USER_CURRENT.child("profileImage").child(uid)
        
        firebaseRef.setValue(firebaseRef.key)
      })
    }
    
    task.resume()
  
  }

  
}