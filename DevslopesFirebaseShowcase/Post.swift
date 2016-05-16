//
//  Post.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation

class Post {
  
  private var _postDescription: String!
  private var _imageUrl: String?
  private var _likes: Int!
  private var _username: String!
  private var _postKey: String!
  
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
  
  init(description: String, imageUrl: String?, username: String) {
    
    self._postDescription = description
    self._imageUrl = imageUrl
    self._username = username
  }
  
  init(postKey: String, dictionary: [String: AnyObject]) {
    
    self._postKey = postKey
    
    if let likes = dictionary["likes"] as? Int {
      self._likes = likes
    }
    
    if let imageUrl = dictionary["imageUrl"] as? String {
      self._imageUrl = imageUrl
      
    }
    
    if let desc = dictionary["description"] as? String {
      self._postDescription = desc
    }
  }
}