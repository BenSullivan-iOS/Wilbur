//
//  Cache.swift
//  Wilbur
//
//  Created by Ben Sullivan on 04/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation

class Cache {
  
  static let shared = Cache()
  
  private init() {}
  
  let imageCache = NSCache()
  let profileImageCache = NSCache()
  let commentedOnCache = NSCache()
  let cellCache = NSCache()
}