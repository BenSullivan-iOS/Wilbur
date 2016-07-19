//
//  PostService.swift
//  Wildlife
//
//  Created by Ben Sullivan on 19/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import FirebaseStorage

enum AlertState {
  case notLoggedIn
  case noPhoto
}

class PostService {
  
  static let shared = PostService()
  
  weak var delegate: CreatePostDelegate? = nil
  
  private init() {}
  
  func uploadImage(localFile: NSURL, username: String, dict: [String: AnyObject]) {
    
    var post = dict
    
    let postRef = DataService.ds.REF_POSTS.childByAutoId()

    let storageRef = FIRStorage.storage().reference()
    let riversRef = storageRef.child("images/\(postRef.key).jpg")
    
    riversRef.putFile(localFile, metadata: nil) { metadata, error in
      
      guard let _ = metadata where error == nil else {
        
        print("Upload Image Error", error)
        
        self.delegate?.postError()
        
      return }
      
      print("success")
      print("metadata")
      
      post["imageUrl"] = "images/\(postRef.key).jpg"
      
      postRef.setValue(post)
      
      self.savePostToUser(postRef.key, username: username)
      
      self.delegate?.postSuccessful()
      
    }
  }
  
  func savePostToUser(postKey: String, username: String) {
    
    let firebasePost = DataService.ds.REF_USER_CURRENT.child("posts").child(postKey)
    firebasePost.setValue(postKey)
    
    let usernameRef = DataService.ds.REF_USER_CURRENT.child("username")
    usernameRef.setValue(username)
    
    let addDefaultText = DataService.ds.REF_POSTS.child(postKey).child("comments").child("placeholder")
    addDefaultText.setValue(1)
    
  }
}