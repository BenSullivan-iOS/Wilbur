//
//  MaterialTextField.swift
//  Fart Club
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

  override func awakeFromNib() {
    
    let color = Constants.shared.shadowColor
    
    layer.cornerRadius = 2.0
    layer.borderColor = UIColor(red: color, green: color, blue: color, alpha: 0.1).CGColor
    layer.borderWidth = 1.0
  }

  //For placeholder
  
  override func textRectForBounds(bounds: CGRect) -> CGRect {
    
    return CGRectInset(bounds, 10, 0)
  }
  
  
  //For editable text
  override func editingRectForBounds(bounds: CGRect) -> CGRect {
    
    return CGRectInset(bounds, 10, 0)
  }
  
}
