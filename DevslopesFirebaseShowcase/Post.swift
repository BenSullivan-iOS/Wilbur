//
//  Post.swift
//  Wilbur
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Firebase

struct Post {
  
  fileprivate var _postDescription: String!
  fileprivate var _imageUrl: String?
  fileprivate var _username: String!
  fileprivate var _postKey: String!
  fileprivate var _postRef: FIRDatabaseReference!
  fileprivate var _audioURL: String!
  fileprivate var _date: String!
  fileprivate var _fakeCount: Int!
  fileprivate var _userKey: String!
  fileprivate var _comments: [String: String] = [:]
  fileprivate var _commentText = [String]()
  fileprivate var _commentUsers = [String]()
  fileprivate var _commentedOn: Bool!
  fileprivate var _answered: String!
  
  var answered: String { return _answered }
  var commentedOn: Bool { return _commentedOn }
  var date: String { return _date }
  var userKey: String { return _userKey }
  var audioURL: String { return _audioURL }
  var postDescription: String { return _postDescription }
  var imageUrl: String? { return _imageUrl }
  var fakeCount: Int { return _fakeCount }
  var username: String { return _username }
  var postKey: String { return _postKey }
  var comments: [String: String] { return _comments }
  var commentUsers: [String] { return _commentUsers }
  var commentText: [String] { return _commentText }
  
  mutating func wasCommentedOn(_ commentedOn: Bool) {
    _commentedOn = commentedOn
  }
  
  mutating func adjustFakeCount(_ addFakeCount: Bool) {
    
    _fakeCount = addFakeCount ? _fakeCount + 1 : _fakeCount - 1
    
    _postRef.child("fakeCount").setValue(_fakeCount)
  }
  
  init(description: String, imageUrl: String?, username: String, audioURL: String, date: String) {
    
    self._postDescription = description
    self._imageUrl = imageUrl
    self._username = username
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
    
    if let answered = dictionary["answered"] as? String {
      self._answered = answered
    } else {
      self._answered = ""
    }
    
    if let comments = dictionary["comments"] as? NSDictionary {
      
      var value = [String: String]()
      
      var array = [NSDictionary](repeating: ["nil":"nil"], count: comments.count)
      
      for i in comments where i.key as! String != "placeholder" {
        
        let first = i.key as! String
        let second = Int(first)!
        
        if array[second] == ["nil":"nil"] {
          array.remove(at: second)
        }
        
        array.insert(comments[i.key as! String] as! NSDictionary, at: second)
        
        let commentValue = i.value as! NSDictionary
        
        for i in commentValue {
          
          let key = i.key as! String
          let newValue = i.value as! String
          value[key] = newValue
          
        }
      }
      
      for i in array {
        
        for a in i where a.0 as! String != "nil" {
          
          self._commentText.append(a.0 as! String)
          self._commentUsers.append(a.1 as! String)
          
        }
        
      }
    }
    
    
    //Bug Fix - Unusual error where one set of comments returned as an NSArray
    if let comments = dictionary["comments"] as? NSArray {
      
      let com = Array(comments)
      
      for i in com.indices {
        
        var key = String(describing: com[i])
        
        key = key.replacingOccurrences(of: ";\n}", with: "")
        key = key.replacingOccurrences(of: "{", with: "")
        key = key.replacingOccurrences(of: "\n    ", with: "")
        key = key.replacingOccurrences(of: "\"", with: "")
        
        self._commentText.append(key.components(separatedBy: " = ").first!)
        self._commentUsers.append(key.components(separatedBy: " = ").last!)
      }
    }
    
    
    self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
    
  }
  
}
