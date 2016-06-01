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
import FDWaveformView
import AVFoundation

protocol PostCellDelegate {
  func showDeletePostAlert(key: String)
}

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PostCellDelegate {
  
  func showDeletePostAlert(key: String) {
    print("showDeletePostAlert")
    displayDeleteAlert(key)
  }
    
  private var posts = [Post]()
  
  static var imageCache = NSCache()
  
  @IBOutlet weak var profileButton: UIButton!
  @IBOutlet weak var navBar: UINavigationBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  private var currentRow = Int()
  
  func displayDeleteAlert(key: String) {
    
    let alert = UIAlertController(title: "Delete post?!", message: "", preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Yes please!", style: .Default, handler: { (action) in
      
      print("Delete post")
      
      let userPostRef = DataService.ds.REF_USER_CURRENT.child("posts").child(key) as FIRDatabaseReference!
      
      userPostRef.removeValue()
      
      let postRef = DataService.ds.REF_POSTS.child(key)
      
      postRef.removeValue()
      
    }))
    
    alert.addAction(UIAlertAction(title: "Actually, no thanks!", style: .Default, handler: nil))
    
    self.presentViewController(alert, animated: true, completion: nil)

  }
  
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
        
        
        
        self.posts.sortInPlace({ (first, second) -> Bool in
          
          let df = NSDateFormatter()
          df.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
          
          return self.isAfterDate(df.dateFromString(first.date)!, endDate: df.dateFromString(second.date)!)
        })
        
        self.tableView.reloadData()
      }
    })
  }
  
  func isAfterDate(startDate: NSDate, endDate: NSDate) -> Bool {
    
    let calendar = NSCalendar.currentCalendar()
    
    let components = calendar.components([.Second],
                                         fromDate: startDate,
                                         toDate: endDate.dateByAddingTimeInterval(86400),
                                         options: [])
    
    if components.day > 0 {
      return true
    } else {
      return false
    }
  }
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("did select", indexPath.row)
    //Add functionality to play audio again
  }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    currentRow = indexPath.row
    if let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as? PostCell {
    
//      cell.request?.cancel()

      let post = posts[indexPath.row]

      var img: UIImage?
      
      if let url = post.imageUrl {
        print("in the cache init")
        img = FeedVC.imageCache.objectForKey(url) as? UIImage
      }
      cell.delegate = self
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
