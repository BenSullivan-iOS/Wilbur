//
//  CreatePost.swift
//  Wilbur
//
//  Created by Ben Sullivan on 28/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

//import FirebaseStorage
//import AVFoundation
//
//class CreatePost {
//  
//  static let shared = CreatePost()
//  
//  private init() {}
//  
//  func downloadAudio(localURL: NSURL, postKey: String) {
//    
//    let storageRef = FIRStorage.storage().reference()
//    let pathReference = storageRef.child("audio/\(postKey).m4a")
//    
//    pathReference.writeToFile(localURL) { (URL, error) -> Void in
//      
//      guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
//      
//      //      AudioControls.shared.play(URL)
//      
//    }
//  }
//  
//  func uploadAudio(localFile: NSURL, firebaseReference: String) {
//    
//    let storageRef = FIRStorage.storage().reference()
//    let riversRef = storageRef.child("audio/\(firebaseReference).m4a")
//    
//    riversRef.putFile(localFile, metadata: nil) { metadata, error in
//      
//      guard let metadata = metadata where error == nil else { print("error", error); return }
//      
//      let downloadURL = metadata.downloadURL
//      
//    }
//    
//  }
//  
//}