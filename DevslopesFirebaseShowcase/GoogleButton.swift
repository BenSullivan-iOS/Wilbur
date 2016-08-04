//
//  GoogleButton.swift
//  Wildlife
//
//  Created by Ben Sullivan on 03/08/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class GoogleButton: GIDSignInButton {
  
  override func awakeFromNib() {
    
    let color = Constants().shadowColor
    
    layer.cornerRadius = 2.0
    layer.shadowColor = UIColor(red: color, green: color, blue: color, alpha: 0.5).CGColor
    layer.shadowOpacity = 1
    layer.shadowRadius = 2
    layer.shadowOffset = CGSizeMake(0.0, 2.0)
  }
}