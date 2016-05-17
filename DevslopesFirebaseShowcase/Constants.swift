//
//  Constants.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//
import UIKit

struct Constants {
  
  static let shared = Constants()
  static let sharedSegues = Constants.Segues()
  static let sharedStatusCodes = Constants.StatusCodes()

  
  let shadowColor: CGFloat = 157.0 / 255.0
  
  let KEY_UID = "uid"
  
  struct Segues {
    
    let loggedIn = "loggedIn"
    let showProfile = "showProfile"
  }
  
  struct StatusCodes {
    
    let STATUS_ACCOUNT_NONEXIST = -8
  }
  
}