//
//  FeedVC.swift
//  Fart Club
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AVFoundation

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
  private var posts = [Post]()
  
  static var imageCache = NSCache()
  
  @IBOutlet weak var profileButton: UIButton!
  @IBOutlet weak var navBar: UINavigationBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    AudioControls.shared.setupRecording()
    
    activityIndicator.color = UIColor(colorLiteralRed: 244/255, green: 81/255, blue: 30/255, alpha: 1)
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.estimatedRowHeight = 414
    
    DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
      
      print(snapshot.value)
      self.posts = []

      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots {
          
          if let postDict = snap.value as? [String: AnyObject] {
            
            let key = snap.key
            let post = Post(postKey: key, dictionary: postDict)
            self.posts.append(post)
            
          }
          print("SNAP: ", snap)
        }
        
        if self.activityIndicator.alpha == 1 {
          self.activityIndicator.alpha = 0
        }
        
        self.tableView.reloadData()
      }
    })
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //Add functionality to play audio again
  }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as? PostCell {
    
      cell.request?.cancel()

      let post = posts[indexPath.row]

      var img: UIImage?
      
      if let url = post.imageUrl {
        print("in the cache init")
        img = FeedVC.imageCache.objectForKey(url) as? UIImage
      }
      
      cell.configureCell(post, img: img)

      return cell
  }
    
    let cell = tableView.dequeueReusableCellWithIdentifier("uploadCell")!
    
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    return self.view.bounds.height - navBar.bounds.height - 20
  }

  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    print("preferred status bar")
    return .LightContent
  }
  
  @IBAction func profileButtonPressed(sender: UIButton) {
    performSegueWithIdentifier(Constants.sharedSegues.showProfile, sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == Constants.sharedSegues.showProfile {
    let backItem = UIBarButtonItem()
    backItem.title = "Back"
    navigationItem.backBarButtonItem = backItem
    }
  }
  
}
