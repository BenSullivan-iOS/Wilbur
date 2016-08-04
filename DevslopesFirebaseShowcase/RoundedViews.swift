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
    
    let color = Constants().shadowColor
    
    layer.cornerRadius = 2.0
    layer.shadowColor = UIColor(red: color, green: color, blue: color, alpha: 0.5).CGColor
    layer.shadowOpacity = 0.8
    layer.shadowRadius = 5.0
    layer.shadowOffset = CGSizeMake(0.0, 2.0)
  }
}

class RoundedImage: UIImageView {
  
  override func awakeFromNib() {
    
    clipsToBounds = true
    layer.cornerRadius = layer.frame.width / 2
  }
}

class RoundedLabel: UILabel {
  
  override func awakeFromNib() {
    
    layer.cornerRadius = 3.0
    layer.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 243/255, blue: 214/255, alpha: 1.0).CGColor
  }
  
  override func drawTextInRect(rect: CGRect) {
    let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 6.0, bottom: 0.0, right: 0.0)
    super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
  }
}