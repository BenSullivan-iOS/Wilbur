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
      
      let userRef = DataService.ds.REF_USER_CURRENT.child("username")
      
      userRef.setValue(user.displayName)
      
      NSUserDefaults.standardUserDefaults().setValue(user.displayName, forKey: "username")
      NSUserDefaults.standardUserDefaults().setValue(user.uid, forKey: Constants.shared.KEY_UID)
      
      self.delegate?.loginSuccessful()
      
    }
    
  }

  
}