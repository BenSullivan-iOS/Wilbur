//
//  ViewController.swift
//  Fart Club
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import Spring

class LoginVC: UIViewController {
  
  @IBOutlet weak var facebookLoginButton: SpringButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    styleButton()
  }
  
  @IBAction func FbBtnPressed(sender: UIButton) {
    
    let facebookLogin = FBSDKLoginManager()
    
    facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) {
      (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
      
      guard let facebookResult = facebookResult where facebookError == nil else { print("Facebook login error:", facebookError); return }
      
      if facebookResult.isCancelled == false {
        
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
          
          guard let user = user where error == nil else { print("Login failed"); return }
          
          user.uid
          
          let provider = ["provider" : user.providerID]
          
          let reference = DataService.ds.REF_USERS
          
          reference.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.value?.uid == user.uid {
              
              if let savedUID = NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) as? String {
                
                if savedUID != user.uid {
                  
                  DataService.ds.createFirebaseUser(user.uid, user: provider)
                  
                }
              }
            }
          })
          
          NSUserDefaults.standardUserDefaults().setValue(user.displayName, forKey: "username")
          NSUserDefaults.standardUserDefaults().setValue(user.uid, forKey: Constants.shared.KEY_UID)
          
          self.performSegueWithIdentifier(Constants.sharedSegues.loggedIn, sender: self)
          
          self.facebookLoginButton.setTitle("Logging in...", forState: .Normal)
        }
      }
    }
    
    self.facebookLoginButton.setTitle("Logging in...", forState: .Normal)
    
  }
  
  func styleButton() {
    
    let color = Constants.shared.shadowColor
    
    facebookLoginButton.layer.shadowColor = UIColor(red: color, green: color, blue: color, alpha: 0.5).CGColor
    facebookLoginButton.layer.shadowOpacity = 0.8
    facebookLoginButton.layer.shadowRadius = 5.0
    facebookLoginButton.layer.shadowOffset = CGSizeMake(0.0, 2.0)
    facebookLoginButton.layer.cornerRadius = 2.0
    facebookLoginButton.clipsToBounds = true
  }
  
  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    
    if let error = error {
      print(error.localizedDescription)
      return
    }
  }
  
  func showErrorAlert(title: String, error: String) {
    
    let alert = UIAlertController(title: title, message: error, preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
      
    }))
    
    presentViewController(alert, animated: true, completion: nil)
  }

}

