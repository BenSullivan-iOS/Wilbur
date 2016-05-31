//
//  CreatePost.swift
//  FartClub
//
//  Created by Ben Sullivan on 28/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Firebase
import FirebaseStorage
import AVFoundation

class CreatePost {
  
  static let shared = CreatePost()
  
  private init() {}
  
  func downloadAudio(localURL: NSURL) {
    print("download audio")
    let storageRef = FIRStorage.storage().reference()
    let pathReference = storageRef.child("audio/recording.m4a")
    
    pathReference.writeToFile(localURL) { (URL, error) -> Void in
      
      guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
      
      print("SUCCESS - ", URL)
      
      //won't need to play here because it'll play locally while downloading for the post
//      self.play(localURL)
    }
  }
  
  func uploadAudio(localFile: NSURL, firebaseReference: String) {
    print("upload audio")
    
    let storageRef = FIRStorage.storage().reference()
    let riversRef = storageRef.child("audio/\(firebaseReference).m4a")
    
    riversRef.putFile(localFile, metadata: nil) { metadata, error in
      
      guard let metadata = metadata where error == nil else { print("error", error); return }
      
      let downloadURL = metadata.downloadURL
      
      print("success", downloadURL)
      
//      CreatePost.shared.downloadAudio(localFile)
    }
    
  }
  
}