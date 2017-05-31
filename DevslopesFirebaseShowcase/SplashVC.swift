//
//  SplashVC.swift
//  Wilbur
//
//  Created by Ben Sullivan on 26/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {
  
  fileprivate var viewInitiallyAppeared = Bool()
  
  override func viewDidAppear(_ animated: Bool) {
    
    didViewAppearFromFeed()
    
    checkForUserLoggedIn()
    
  }
  
  
  //Displays signup if not logged in and main app if logged in
  
  func checkForUserLoggedIn() {
    
    dismiss(animated: true, completion: nil)
    
    if DataService.ds.currentUserKey != nil {
      self.performSegue(withIdentifier: Constants.Segues.loggedInFromSplash.rawValue, sender: self)
    } else {
      self.performSegue(withIdentifier: Constants.Segues.signUp.rawValue, sender: self)
    }
    
    viewInitiallyAppeared = true
  }
  
  
  //View reappears if error in feed, user taken to signup
  
  func didViewAppearFromFeed() {
    
    if viewInitiallyAppeared {
      
      dismiss(animated: true, completion: {
        
        self.performSegue(withIdentifier: Constants.Segues.signUp.rawValue, sender: self)
        
      })
    }
  }

}
