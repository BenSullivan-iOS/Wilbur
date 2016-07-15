//
//  ViewController.swift
// Wilbur
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import Firebase

class LoginVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
  
  @IBOutlet weak var facebookLoginButton: UIButton!
  @IBOutlet weak var guestButton: UIButton!
  
  @IBAction func guestButtonPressed(sender: UIButton) {
    
    presentFeedVC()
  }
  
  func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError?) {
    
    guard error == nil else { print(error); return }
    
    let authentication = user.authentication
    let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                                 accessToken: authentication.accessToken)
    
    FIRAuth.auth()?.signInWithCredential(credential) { user, error in
      
      print("did sign in for user", error)
      print(user)
      
      guard let user = user where error == nil else { print(error); return }
      
      let userRef = DataService.ds.REF_USER_CURRENT.child("username")
      
      userRef.setValue(user.displayName)
      
      NSUserDefaults.standardUserDefaults().setValue(user.displayName, forKey: "username")
      NSUserDefaults.standardUserDefaults().setValue(user.uid, forKey: Constants.shared.KEY_UID)
      
      self.presentFeedVC()
    }
    
  }
  
  func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
              withError error: NSError!) {
    
    print("did disconnect with user")
    // Perform any operations when the user disconnects from app here.
    // ...
  }

  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    styleFacebookLoginButton()
    
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self



    // Uncomment to automatically sign in the user.
    //GIDSignIn.sharedInstance().signInSilently()
    
    // TODO(developer) Configure the sign-in button look/feel
    // ...
  }
  
//  func returnUserData() {
//    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
//    graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
//      
//      if ((error) != nil)
//      {
//        // Process error
//        print("Error: \(error)")
//      }
//      else
//      {
//        print("fetched user: \(result)")
//        
//        if let id: NSString = result.valueForKey("id") as? NSString {
//          print("ID is: \(id)")
//          self.returnUserProfileImage(id)
//        } else {
//          print("ID es null")
//        }
//        
//        
//      }
//    })
//  }
//  
//  func returnUserProfileImage(accessToken: NSString)
//  {
//    var userID = accessToken as NSString
//    var facebookProfileUrl = NSURL(string: "https://graph.facebook.com/\(userID)/picture?type=large")
//    
//    if let data = NSData(contentsOfURL: facebookProfileUrl!) {
//      
//      print(UIImage(data: data))
////      imageProfile.image = UIImage(data: data)
//    } else {
//      print("buggar")
//      
//    }
//    
//  }
  
  @IBAction func FbBtnPressed(sender: UIButton) {
    
    let facebookLogin = FBSDKLoginManager()
    
    facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) {
      (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
      
      guard let facebookResult = facebookResult where facebookError == nil else { print("Facebook login error:", facebookError); return }
      
      if facebookResult.isCancelled == false {
        
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
          
          guard let user = user where error == nil else { print("Login failed", error); return }
          
          let provider = ["provider" : user.providerID]
          
          let reference = DataService.ds.REF_USERS
          
          reference.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.value?.uid == user.uid {
            
              if let savedUID = DataService.ds.currentUserKey {
                
                if savedUID != user.uid {
                
                  DataService.ds.createFirebaseUser(user.uid, user: provider)
                  
                }
              }
            }
          })
          
          NSUserDefaults.standardUserDefaults().setValue(user.displayName, forKey: "username")
          NSUserDefaults.standardUserDefaults().setValue(user.uid, forKey: Constants.shared.KEY_UID)

          self.presentFeedVC()
          
          self.facebookLoginButton.setTitle("Logging in...", forState: .Normal)
        }
      }
    }
    
    self.facebookLoginButton.setTitle("Logging in...", forState: .Normal)
    
  }
  
  func presentFeedVC() {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let feedVC = storyboard.instantiateViewControllerWithIdentifier("NavigationContainer")
    
    self.presentViewController(feedVC, animated: true, completion: nil)
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
  
  
  func styleFacebookLoginButton() {
    
    let shadow = Constants.shared.shadowColor
    
    facebookLoginButton.layer.shadowColor = UIColor(red: shadow, green: shadow, blue: shadow, alpha: 0.5).CGColor
    facebookLoginButton.layer.shadowOpacity = 0.8
    facebookLoginButton.layer.shadowRadius = 5.0
    facebookLoginButton.layer.shadowOffset = CGSizeMake(0.0, 2.0)
    facebookLoginButton.layer.cornerRadius = 2.0
    facebookLoginButton.clipsToBounds = true
  }
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}

