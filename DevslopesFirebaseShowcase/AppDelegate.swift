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
        
    //Quite a cool colour, consider this instead of orange?
//    UINavigationBar.appearance().barTintColor = UIColor(red: 42/255.0, green: 140/255.0, blue: 166/255.0, alpha: 0.5)
    
    //Back button tint color change
    
    UINavigationBar.appearance().barStyle = .Default
    UINavigationBar.appearance().tintColor = .whiteColor()
      
//      UIColor(red: 204/255.0, green: 255/255.0, blue: 204/255.0, alpha: 1)
    
    //Navigation Menu font tint color change
    
//    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 204/255.0, green: 255/255.0, blue: 204/255.0, alpha: 1), NSFontAttributeName: UIFont(name: "FightThis", size: 25)!]//UIColor(red: 42/255.0, green: 140/255.0, blue: 166/255.0, alpha: 1.0)
    
//    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    FIRApp.configure()
    
    return FBSDKApplicationDelegate.sharedInstance()
      .application(application, didFinishLaunchingWithOptions: launchOptions)
  
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
}

