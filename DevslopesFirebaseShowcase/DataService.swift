//
//  DataService.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://mydevslopesapp.firebaseio.com"

class DataService {
  
  static let ds = DataService()
  
  private init() {}
  
  private var _REF_BASE = Firebase(url: "\(URL_BASE)")
  private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
  private var _REF_USERS = Firebase(url: "\(URL_BASE)/Users")

  var REF_BASE: Firebase {
    return _REF_BASE
  }
  
  var REF_POSTS: Firebase {
    return _REF_POSTS
  }
  
  var REF_USERS: Firebase {
    return _REF_USERS
  }
  
  
  func createFirebaseUser(uid: String, user: [String:String]) {
    
    REF_USERS.childByAppendingPath(uid).setValue(user)
    
    print("Create firebase user")
    
    
  }
}