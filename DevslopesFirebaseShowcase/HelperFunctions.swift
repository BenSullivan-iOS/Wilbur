//
//  HelperFunctions.swift
//  Wilbur
//
//  Created by Ben Sullivan on 04/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation

protocol HelperFunctions {
  
  func docsDirect() -> String
}

extension HelperFunctions {
  
  func docsDirect() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory + "/"
  }
}

class ProfileImageTracker {
  
  static var imageLocations: Set = Set<String>()
}

//Allows post struct to be passed as AnyObject in notifications
class Wrap<T> {
  var wrappedValue: T
  init(_ theValue: T) {
    wrappedValue = theValue
  }
}