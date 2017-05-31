//
//  AppDelegate.swift
//  Wilbur
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    registerForNotifications()
    
    FIRApp.configure()
    
    GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
    
    self.window = UIWindow(frame: UIScreen.main.bounds)

    var initialViewController: UIViewController?
    
    if UserDefaults.standard.value(forKey: Constants.KEY_UID) != nil {
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      initialViewController = storyboard.instantiateViewController(withIdentifier: "NavigationContainer")

    } else {
      
      let storyboard = UIStoryboard(name: "Login", bundle: nil)
      initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
    }
        
    self.window?.rootViewController = initialViewController
    self.window?.makeKeyAndVisible()
    
    UINavigationBar.appearance().barStyle = .default
    
    UINavigationBar.appearance().titleTextAttributes = [
      NSFontAttributeName: UIFont(name: "Cochin", size: 25)!,
      NSForegroundColorAttributeName: UIColor.white]
        
    UINavigationBar.appearance().tintColor = .white


    return FBSDKApplicationDelegate.sharedInstance()
      .application(application, didFinishLaunchingWithOptions: launchOptions)
  
  }
  
  func registerForNotifications() {
    
    let settings: UIUserNotificationSettings =
      UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
    UIApplication.shared.registerUserNotificationSettings(settings)
    UIApplication.shared.registerForRemoteNotifications()
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DataService.ds.downloadImage(DataService.ds.posts)
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
      FBSDKAppEvents.activateApp()
  }

  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
  //MARK: - GOOGLE AUTHENTICATION
  
  func application(_ application: UIApplication,
                   open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
    return GIDSignIn.sharedInstance().handle(url,
                                                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                annotation: options[UIApplicationOpenURLOptionsKey.annotation])
  }
  
}

