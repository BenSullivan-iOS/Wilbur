//
//  Post.swift
//  Fart Club
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Firebase

class Post {
  
  private var _postDescription: String!
  private var _imageUrl: String?
  private var _likes: Int!
  private var _username: String!
  private var _postKey: String!
  private var _postRef: FIRDatabaseReference!
  private var _audioURL: String!
  private var _date: String!
  
  var date: String {
    return _date
  }
  var audioURL: String {
    return _audioURL
  }
  var postDescription: String {
    return _postDescription
  }
  var imageUrl: String? {
    return _imageUrl
  }
  var likes: Int {
    return _likes
  }
  var username: String {
    return _username
  }
  
  var postKey: String {
    return _postKey
  }
  
  func adjustLikes(addLike: Bool) {
    
    _likes = addLike ? _likes + 1 : _likes - 1
    
    _postRef.child("likes").setValue(_likes)
  }
  
  init(description: String, imageUrl: String?, username: String, audioURL: String, date: String) {
    
    self._postDescription = description
    self._imageUrl = imageUrl
    self._username = username
    self._audioURL = audioURL
    self._date = date
  }
  
  init(postKey: String, dictionary: [String: AnyObject]) {
    
    self._postKey = postKey
    print("postInit")
    if let audio = dictionary["audio"] as? String {
      print("Post if let audio")
      
      self._audioURL = audio
      
//      let path = AudioControls.shared.getDocumentsDirectory()
//      let stringPath = String(path) + "/" + audio
//      let finalPath = NSURL(fileURLWithPath: stringPath)
//      CreatePost.shared.downloadAudio(finalPath, postKey: _postKey)
      
//      AudioControls.shared.play(finalPath!)
    }
    
    self._date = dictionary["date"] as? String
    
    self._username = dictionary["user"] as? String
    
    
    if let likes = dictionary["likes"] as? Int {
      self._likes = likes
    }
    
    if let imageUrl = dictionary["imageUrl"] as? String {
      self._imageUrl = imageUrl
      
    }
    
    if let desc = dictionary["description"] as? String {
      self._postDescription = desc
    }
    
    self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
  }
}