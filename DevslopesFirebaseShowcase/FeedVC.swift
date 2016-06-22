//
//  FeedVC.swift
//  Wilbur
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import FDWaveformView
import AVFoundation

protocol PostCellDelegate {
  func showDeletePostAlert(key: String)
  func reloadTable()
}

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PostCellDelegate {
  
  private var posts = [Post]()
  private var currentRow = Int()
  
  @IBOutlet weak var profileButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  
  func reloadTable() {
    tableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.estimatedRowHeight = tableView.rowHeight
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    self.tableView.scrollsToTop = false
    
    downloadTableContent()
    
    AppState.shared.currentState = .Feed
    
//    AudioControls.shared.setupRecording()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: #selector(self.checkLoggedIn), userInfo: nil, repeats: false)
  }
  
  
  override func viewWillAppear(animated: Bool) {
    AppState.shared.currentState = .Feed
    
//    tableView.reloadData()
  }
  
  //MARK: - TABLE VIEW
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
//    let path = HelperFunctions.getDocumentsDirectory()
//    let stringPath = String(path) + "/" + posts[indexPath.row].audioURL
//    let finalPath = NSURL(fileURLWithPath: stringPath)
//    CreatePost.shared.downloadAudio(finalPath, postKey: posts[indexPath.row].postKey)
    
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if AppState.shared.currentState == .Feed {
      
      currentRow = indexPath.row
      
      if let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as? PostCell {
        
        let post = posts[indexPath.row]
        
        var img: UIImage?
        var profileImg: UIImage?
        
        if let url = post.imageUrl {
          
          img = Cache.FeedVC.imageCache.objectForKey(url) as? UIImage
        }
        
        if let profileImage = Cache.FeedVC.profileImageCache.objectForKey(post.userKey) as? UIImage {
          
          profileImg = profileImage
          cell.profileImg.image = profileImg
          
          if post.username == NSUserDefaults.standardUserDefaults().valueForKey("username") as? String && TempProfileImageStorage.shared.profileImage == nil {
            print("setting temp profile image")
            TempProfileImageStorage.shared.profileImage = profileImg

          }
          
        }
        
        cell.delegate = self
        cell.configureCell(post, img: img, profileImg: profileImg)
        
        return cell
      }
    }
    return UITableViewCell()
  }
  
  
  //MARK: - ALERTS
  
  func showDeletePostAlert(key: String) {
    displayDeleteAlert(key)
  }
  
  func displayDeleteAlert(key: String) {
    
    let alert = UIAlertController(title: "Delete post?!", message: "", preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Yes please!", style: .Default, handler: { (action) in
      
      let userPostRef = DataService.ds.REF_USER_CURRENT.child("posts").child(key) as FIRDatabaseReference!
      userPostRef.removeValue()
      
      let postRef = DataService.ds.REF_POSTS.child(key)
      postRef.removeValue()
      
      let storageAudioRef = FIRStorage.storage().reference()
      storageAudioRef.child("audio/"+key+".m4a")//.child(key + ".jpg")
      
      print("storage audio ref: ", storageAudioRef.fullPath)
      
      storageAudioRef.deleteWithCompletion({ (error) in
        guard error == nil else { print(error.debugDescription) ; return }
        print("storage audio removed")
      })
      
//      let storageImageRef = FIRStorage.storage()
//      
//      storageImageRef.child("images/"+key+".jpg")//.child(key + ".m4a")
//      print("storage image ref: ", storageImageRef.fullPath)
//
//      storageImageRef.deleteWithCompletion({ (error) in
//        guard error == nil else { print(error.debugDescription) ; return }
//        print("storage image removed")
//      })
      
    }))
    
    alert.addAction(UIAlertAction(title: "Actually, no thanks!", style: .Default, handler: nil))
    
    self.presentViewController(alert, animated: true, completion: nil)
    
  }
  
  //MARK: - DOWNLOAD CONTENT
  
  func downloadTableContent() {
    
    DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
      
      self.posts = []
      
      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots {
          
          if let postDict = snap.value as? [String: AnyObject] {
            
            let key = snap.key
            let post = Post(postKey: key, dictionary: postDict)
            self.posts.append(post)
            
          }
        }
        
        self.posts.sortInPlace({ (first, second) -> Bool in
          
          let df = NSDateFormatter()
          df.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
          
          if let firstDate = df.dateFromString(first.date), secondDate = df.dateFromString(second.date) {
            
            return self.isAfterDate(firstDate, endDate: secondDate)
          }
          
          return true
        })
        
        self.tableView.reloadData()
      }
    })
  }

  
  //MARK: - OTHER FUNCTIONS
  
  func checkLoggedIn() {
    
    if posts.isEmpty {
      NSUserDefaults.standardUserDefaults().setValue(nil, forKey: Constants.shared.KEY_UID)
      dismissViewControllerAnimated(true, completion: nil)
    }
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
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}
