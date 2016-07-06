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
  private var _username: String!
  private var _postKey: String!
  private var _postRef: FIRDatabaseReference!
  private var _audioURL: String!
  private var _date: String!
  private var _fakeCount: Int!
  private var _userKey: String!
  private var _comments: [String: String] = [:]
  private var _commentText = [String]()
  private var _commentUsers = [String]()
  private var _commentedOn: Bool!
  
  func wasCommentedOn(commentedOn: Bool) {
    _commentedOn = commentedOn
  }
  
  var commentedOn: Bool {
    return _commentedOn
  }
  
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
  var commentUsers: [String] {
    return _commentUsers
  }
  var commentText: [String] {
    return _commentText
  }
  
  func adjustFakeCount(addFakeCount: Bool) {
    
    _fakeCount = addFakeCount ? _fakeCount + 1 : _fakeCount - 1
    
    _postRef.child("fakeCount").setValue(_fakeCount)
  }
  
  init(description: String, imageUrl: String?, username: String, audioURL: String, date: String) {
    
    self._postDescription = description
    self._imageUrl = imageUrl
    self._username = username
//    self._audioURL = audioURL
    self._date = date
    
  }
  

  
  init(postKey: String, dictionary: [String: AnyObject]) {
    
    self._commentedOn = false
    
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
      
      var value = [String: String]()
      
      var array = [NSDictionary](count: comments.count, repeatedValue: ["nil":"nil"])
      
      for i in comments where i.key as! String != "placeholder" {
        
//        print("i in comments", i.key)
        
        //array of dictionaries then sort?
        
        let first = i.key as! String
        let second = Int(first)!
        print("array = ", array)
        if array[second] == ["nil":"nil"] {
          array.removeAtIndex(second)
        }
        array.insert(comments[i.key as! String] as! NSDictionary, atIndex: second)
        
        let commentValue = i.value as! NSDictionary
        
        for i in commentValue {
          
          print(i.value)
          
          let key = i.key as! String
          let newValue = i.value as! String
          value[key] = newValue
          
        }
      }
//      print("Array = ", array)
      
      for i in array {

        for a in i where a.0 as! String != "nil" {
          
          print(a.0)
          
          self._commentText.append(a.0 as! String)
          self._commentUsers.append(a.1 as! String)
          
          self._comments[a.0 as! String] = a.1 as! String

        }
        
      }
      print(self._comments)
//      for i in value {
//
//        self._comments[i.0] = i.1
//        
//      }
      
      
//      for i in comments {
//        
//        if let key = i.key as? String, value = i.value as? String {
//          
//          self._comments[key] = value
//          
//        }
//      }
    }
    
    self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
  }
  
}