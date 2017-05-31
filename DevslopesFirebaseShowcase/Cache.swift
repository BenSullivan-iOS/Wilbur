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
  
  fileprivate init() {}
  
  let imageCache = NSCache<AnyObject, AnyObject>()
  let profileImageCache = NSCache<AnyObject, AnyObject>()
  let commentedOnCache = NSCache<AnyObject, AnyObject>()
  let labelCache = NSCache<AnyObject, AnyObject>()
}
