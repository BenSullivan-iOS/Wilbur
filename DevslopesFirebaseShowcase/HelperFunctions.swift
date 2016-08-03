//
//  HelperFunctions.swift
//  Wilbur
//
//  Created by Ben Sullivan on 04/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation

protocol HelperFunctions {
  
  func direct() -> NSString
  func getDocumentsDirectory() -> NSURL
}

extension HelperFunctions {
  
  func direct() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
  
  func getDocumentsDirectory() -> NSURL {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    
    let url = NSURL(string: documentsDirectory)!
    
    return url
  }
}