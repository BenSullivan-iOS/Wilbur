//
//  CreatePostTest.swift
//  Wildlife
//
//  Created by Ben Sullivan on 21/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class CreatePostTest: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var image: UIImageView!
  
  func textViewDidBeginEditing(textView: UITextView) {
    descriptionText.text = ""
    descriptionText.textColor = .grayColor()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    descriptionText.delegate = self
    descriptionText.layer.cornerRadius = 3.0
    descriptionText.layer.borderWidth = 1.0
    descriptionText.layer.borderColor = UIColor(colorLiteralRed: 170/255, green: 170/255, blue: 170/255, alpha: 0.2).CGColor
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }
}
