//
//  Constants.swift
//  Wilbur
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

struct Constants {
  
  static let KEY_UID = "uid"
  static let shadowColor: CGFloat = 157.0 / 255.0
  
  enum Segues: String {
    
    case loggedIn
    case showProfile
    case loggedInFromSplash
    case signUp
    case embedSegue
    case comments
    case showComments
  }
  
}
