//
//  SplashVC.swift
//  FartClub
//
//  Created by Ben Sullivan on 26/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {
  
  private var viewAppearedFromFeed = Bool()

  override func viewDidLoad() {
    super.viewDidLoad()
    
//    NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(SplashVC.checkForUserLoggedIn), userInfo: nil, repeats: false)
  
  }
  
  override func viewDidAppear(animated: Bool) {
    
    if viewAppearedFromFeed {
      
      dismissViewControllerAnimated(true, completion: {
        
        self.performSegueWithIdentifier(Constants.sharedSegues.signUp, sender: self)

      })
    }
    checkForUserLoggedIn()

  }
  
  func checkForUserLoggedIn() {
    
    dismissViewControllerAnimated(true, completion: nil)
    
    if NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) != nil {
      self.performSegueWithIdentifier(Constants.sharedSegues.loggedInFromSplash, sender: self)
    } else {
      self.performSegueWithIdentifier(Constants.sharedSegues.signUp, sender: self)
    }
    
    viewAppearedFromFeed = true
  }
}
