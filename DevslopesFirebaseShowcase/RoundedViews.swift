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
    
    let color = Constants.shadowColor
    
    layer.cornerRadius = 2.0
    layer.shadowColor = UIColor(red: color, green: color, blue: color, alpha: 0.5).cgColor
    layer.shadowOpacity = 0.8
    layer.shadowRadius = 5.0
    layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
  }
}

class RoundedImage: UIImageView {
  
  override func awakeFromNib() {
    
    clipsToBounds = true
    layer.cornerRadius = layer.frame.width / 2
  }
}

class ColoredLabel: UILabel {
  
  override func awakeFromNib() {
    
    layer.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 243/255, blue: 214/255, alpha: 1.0).cgColor
  }
  
  override func drawText(in rect: CGRect) {
    let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 6.0, bottom: 0.0, right: 0.0)
    super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
  }
}
