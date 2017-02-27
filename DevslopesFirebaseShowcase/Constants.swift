//
//  Constants.swift
//  Wilbur
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit


struct Constants {
  
  let sharedStatusCodes = Constants.StatusCodes()
  
  let shadowColor: CGFloat = 157.0 / 255.0
  
  static let KEY_UID = "uid"
  
  enum Segues: String {
    
    case loggedIn
    case showProfile
    case loggedInFromSplash
    case signUp
    case embed
    case comments
  }
  
  struct StatusCodes {
    
    let STATUS_ACCOUNT_NONEXIST = -8
  }
  
}
