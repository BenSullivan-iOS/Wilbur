//
//  extensions.swift
//  Wilbur
//
//  Created by Ben Sullivan on 17/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
  
  open override var childViewControllerForStatusBarHidden : UIViewController? {
    return self.topViewController
  }
  
  open override var childViewControllerForStatusBarStyle : UIViewController? {
    return self.topViewController
  }
}

extension Array {
  func ref (_ i:Int) -> Element? {
    return 0 <= i && i < count ? self[i] : nil
  }
}
