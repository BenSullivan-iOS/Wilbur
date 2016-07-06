//
//  extensions.swift
// Wilbur
//
//  Created by Ben Sullivan on 17/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
  
  public override func childViewControllerForStatusBarHidden() -> UIViewController? {
    return self.topViewController
  }
  
  public override func childViewControllerForStatusBarStyle() -> UIViewController? {
    return self.topViewController
  }
}