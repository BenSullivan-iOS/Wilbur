//
//  RoundedViews.swift
//  Wilbur
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class MaterialView: UIView {
  
  override func awakeFromNib() {
    
    let color = Constants.shared.shadowColor
    
    layer.cornerRadius = 2.0
    layer.shadowColor = UIColor(red: color, green: color, blue: color, alpha: 0.5).CGColor
    layer.shadowOpacity = 0.8
    layer.shadowRadius = 5.0
    layer.shadowOffset = CGSizeMake(0.0, 2.0)
  }
  
}