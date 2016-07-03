//
//  Post.swift
//  Wilbur
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
  private var _fakeCount: Int!
  private var _userKey: String!
  private var _comments: [String: String] = [:]
  
  var date: String {
    return _date
  }
  var userKey: String {
    return _userKey
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
  var fakeCount: Int {
    return _fakeCount
  }
  var username: String {
    return _username
  }
  var postKey: String {
    return _postKey
  }
  var comments: [String: String] {
    return _comments
  }
  
  func adjustLikes(addLike: Bool) {
    
    _likes = addLike ? _likes + 1 : _likes - 1
    
    _postRef.child("likes").setValue(_likes)
  }
  
  func adjustFakeCount(addFakeCount: Bool) {
    
    _fakeCount = addFakeCount ? _fakeCount + 1 : _fakeCount - 1
    
    _postRef.child("fakeCount").setValue(_fakeCount)
  }
  
  init(description: String, imageUrl: String?, username: String, audioURL: String, date: String) {
    
    self._postDescription = description
    self._imageUrl = imageUrl
    self._username = username
    self._audioURL = audioURL
    self._date = date
  }
  
  var testString = String()
  
  init(postKey: String, dictionary: [String: AnyObject]) {
    
    self._postKey = postKey
    
    if let audio = dictionary["audio"] as? String {
      self._audioURL = audio
    }
    
    if let date = dictionary["date"] as? String {
      self._date = date
    }
    
    if let username = dictionary["user"] as? String {
      self._username = username
    }
    
    if let likes = dictionary["likes"] as? Int {
      self._likes = likes
    }
    
    if let userKey = dictionary["userKey"] as? String {
      self._userKey = userKey
    }
    
    if let fakeCount = dictionary["fakeCount"] as? Int {
      self._fakeCount = fakeCount
    }
    
    if let imageUrl = dictionary["imageUrl"] as? String {
      self._imageUrl = imageUrl
    }
    
    if let desc = dictionary["description"] as? String {
      self._postDescription = desc
    }
    
    if let comments = dictionary["comments"] as? NSDictionary {
      //      self.testString = comments
//      print(comments)
      
      for i in comments {
        
        if let key = i.key as? String, value = i.value as? String {
//          
//          print(key)
//          print(value)
          
          self._comments[key] = value
          
        }
      }
      
      for i in _comments {
        
        print(i.0)
        print(i.1)
      }
      print("output:")
      print(self._comments)
      
      
    }
    
    self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
  }
  
}