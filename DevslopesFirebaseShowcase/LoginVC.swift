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
  
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var facebookLoginButton: SpringButton!

  func styleButton() {
    
    let color = Constants.shared.shadowColor
    
    facebookLoginButton.layer.shadowColor = UIColor(red: color, green: color, blue: color, alpha: 0.5).CGColor
    facebookLoginButton.layer.shadowOpacity = 0.8
    facebookLoginButton.layer.shadowRadius = 5.0
    facebookLoginButton.layer.shadowOffset = CGSizeMake(0.0, 2.0)
    facebookLoginButton.layer.cornerRadius = 2.0
    facebookLoginButton.clipsToBounds = true
    
  }
  override func viewDidLoad() {
    super.viewDidLoad()

    styleButton()
    
  }
    
  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    
    if let error = error {
      print(error.localizedDescription)
      return
    }
  }
  
  @IBAction func FbBtnPressed(sender: UIButton) {
    
    let facebookLogin = FBSDKLoginManager()
    
    facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) {
      (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
      
      guard let facebookResult = facebookResult where facebookError == nil else { print("Facebook login error:", facebookError); return }
      
      let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
      
      print("Successfully logged in ", facebookResult, accessToken)
      //Custom syntax, might not work
      //Save a user to firebase
      
      let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
      
      FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
        
        guard let user = user where error == nil else { print("Login failed"); return }

        
        user.uid
        print("got here", user)
        
        let provider = ["provider" : user.providerID]

        DataService.ds.createFirebaseUser(user.uid, user: provider)
        
        NSUserDefaults.standardUserDefaults().setValue(user.uid, forKey: Constants.shared.KEY_UID)
        

        self.performSegueWithIdentifier(Constants.sharedSegues.loggedIn, sender: self)


      }
    }
//      DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken) { error, authData in
////
//        guard let authData = authData where error == nil else { print("Login failed"); return }
//        
//        print("Logged in to firebase, ", authData)
//        
//        let provider = ["provider" : authData.provider!]
//        
//
//        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: Constants.shared.KEY_UID)
//
//        self.performSegueWithIdentifier("loggedIn", sender: self)
//        
//        
//        
//      }
//    }
  }
  
  
//  @IBAction func attemptLogin(sender: UIButton!) {
    
//    if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
//      
//      DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
//        
//        guard let authData = authData where error == nil else {
//          
//          print(error)
//          
//          if error.code == Constants.sharedStatusCodes.STATUS_ACCOUNT_NONEXIST {
//            
//            DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
//              
//              guard let result = result where error == nil else { self.showErrorAlert("buggar", error: "couldn't create account")
//              
//               print(error)
//                
//                self.showErrorAlert("buggar", error: "Didn't exist and couldn't create user")
//              
//                return
//              }
//              
//              NSUserDefaults.standardUserDefaults().setValue(result[Constants.shared.KEY_UID], forKey: Constants.shared.KEY_UID)
//              
//              DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
//                
//                guard let authData = authData where err == nil else { print("buggar!"); return }
//                
//                let user = ["provider" : authData.provider!, "username": email, "password": pwd]
//                
//                DataService.ds.createFirebaseUser(authData.uid, user: user)
//                
//                print("success", authData)
//                self.performSegueWithIdentifier(Constants.sharedSegues.loggedIn, sender: self)
//                
//              })
//            })
//          }
//          
//          
//          return }
//        
//        print(authData)
//        print("got here")
//        self.performSegueWithIdentifier(Constants.sharedSegues.loggedIn, sender: self)
//
//      })
//      
//    } else {
//      
//      showErrorAlert("Fields incomplete", error: "Enter an email and password")
//    }
    
//  }
  
  func showErrorAlert(title: String, error: String) {
    
    let alert = UIAlertController(title: title, message: error, preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
      
      print("Error OK'd")
      
    }))
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
//  override func preferredStatusBarStyle() -> UIStatusBarStyle {
//    return .LightContent
//  }

}
