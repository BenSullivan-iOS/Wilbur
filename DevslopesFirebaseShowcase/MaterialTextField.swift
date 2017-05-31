//
//  MaterialTextField.swift
//  Wilbur
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

  override func awakeFromNib() {
    
    let color = Constants.shadowColor
    layer.borderColor = UIColor(red: color, green: color, blue: color, alpha: 0.1).cgColor
    layer.borderWidth = 1.0
  }

  //For placeholder
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    
    return bounds.insetBy(dx: 10, dy: 0)
  }
  
  
  //For editable text
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    
    return bounds.insetBy(dx: 10, dy: 0)
  }
  
}
