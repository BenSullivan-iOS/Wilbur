//
//  DataService.swift
//  Fart Club
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()

class DataService {
  
  static let ds = DataService()
  
  private init() {}
  
  private var _REF_BASE = URL_BASE
  private var _REF_POSTS = URL_BASE.child("posts")
  private var _REF_USERS = URL_BASE.child("Users")

  var REF_BASE: FIRDatabaseReference {
    return _REF_BASE
  }
  
  var REF_POSTS: FIRDatabaseReference {
    return _REF_POSTS
  }
  
  var REF_USERS: FIRDatabaseReference {
    return _REF_USERS
  }
  
  var REF_USER_CURRENT: FIRDatabaseReference {
    
    let uid = NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) as! String
    
    let user = URL_BASE.child("Users")
    
    return user
  }
  
  
  func createFirebaseUser(uid: String, user: [String:String]) {
    
    REF_USERS.child(uid).setValue(user)
    
    print("Create firebase user")
    
    
  }
}