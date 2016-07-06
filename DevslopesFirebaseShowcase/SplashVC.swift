//
//  SplashVC.swift
// Wilbur
//
//  Created by Ben Sullivan on 26/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {
  
  private var viewInitiallyAppeared = Bool()
  
  override func viewDidAppear(animated: Bool) {
    
    didViewAppearFromFeed()
    
    checkForUserLoggedIn()
    
  }
  
  
  //Displays signup if not logged in and main app if logged in
  
  func checkForUserLoggedIn() {
    
    dismissViewControllerAnimated(true, completion: nil)
    
    if NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) != nil {
      self.performSegueWithIdentifier(Constants.sharedSegues.loggedInFromSplash, sender: self)
    } else {
      self.performSegueWithIdentifier(Constants.sharedSegues.signUp, sender: self)
    }
    
    viewInitiallyAppeared = true
  }
  
  
  //View reappears if error in feed, user taken to signup
  
  func didViewAppearFromFeed() {
    
    if viewInitiallyAppeared {
      
      dismissViewControllerAnimated(true, completion: {
        
        self.performSegueWithIdentifier(Constants.sharedSegues.signUp, sender: self)
        
      })
    }
  }

}
