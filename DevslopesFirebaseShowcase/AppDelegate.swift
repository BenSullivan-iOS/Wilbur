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
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    registerForNotifications()
    
    FIRApp.configure()
    
    GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
    
    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

    var initialViewController: UIViewController?
    
    if NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) != nil {
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      initialViewController = storyboard.instantiateViewControllerWithIdentifier("NavigationContainer")

    } else {
      
      let storyboard = UIStoryboard(name: "Login", bundle: nil)
      initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginVC")
    }
        
    self.window?.rootViewController = initialViewController
    self.window?.makeKeyAndVisible()
    
    UINavigationBar.appearance().barStyle = .Default
    
    UINavigationBar.appearance().titleTextAttributes = [
      NSFontAttributeName: UIFont(name: "Cochin", size: 25)!,
      NSForegroundColorAttributeName: UIColor.whiteColor()]
        
    UINavigationBar.appearance().tintColor = .whiteColor()


    return FBSDKApplicationDelegate.sharedInstance()
      .application(application, didFinishLaunchingWithOptions: launchOptions)
  
  }
  
  func registerForNotifications() {
    
    let settings: UIUserNotificationSettings =
      UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    UIApplication.sharedApplication().registerForRemoteNotifications()
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    DataService.ds.downloadImage(DataService.ds.posts)
  }

  func applicationDidBecomeActive(application: UIApplication) {
      FBSDKAppEvents.activateApp()
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
  //MARK: - GOOGLE AUTHENTICATION
  
  func application(application: UIApplication,
                   openURL url: NSURL, options: [String: AnyObject]) -> Bool {
    return GIDSignIn.sharedInstance().handleURL(url,
                                                sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
  }
  
}

