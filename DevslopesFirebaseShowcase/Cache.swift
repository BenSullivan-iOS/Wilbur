//
//  Cache.swift
// Wilbur
//
//  Created by Ben Sullivan on 04/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation

class Cache {
  
  class FeedVC {
    static let imageCache = NSCache()
    static let profileImageCache = NSCache()
    static let commentedOnCache = NSCache()
  }
}