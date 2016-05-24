//
//  ProfileVC.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 17/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation
import UIKit

class ProfileVC: UIViewController {
  
  @IBOutlet weak var profileImage: UIImageView!
  
  @IBAction func popOffButtonPressed(sender: UIButton) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func viewDidLoad() {
    
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
    profileImage.clipsToBounds = true
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}