//
//  FeedVC.swift
//  Wilbur
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import FirebaseStorage

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PostCellDelegate, ReloadTableDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  private let indicator = UIActivityIndicatorView()
    
  //MARK: - VC LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedVC.reloadTable), name: "reloadTables", object: nil)
    
    self.tableView.estimatedRowHeight = 400
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    self.tableView.scrollsToTop = false
    DataService.ds.delegate = self
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{

      DataService.ds.downloadTableContent()
//
//    dispatch_async(dispatch_get_main_queue(),{
//
//      
//        })
      })
    
    addIndicator()
    
    AppState.shared.currentState = .Feed
    
    tableView.delegate = self
    tableView.dataSource = self
    
//    NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(self.checkLoggedIn), userInfo: nil, repeats: false)
  }
  
  
  override func viewWillAppear(animated: Bool) {
    
    if AppState.shared.currentState == .PresentLoginFromComments {
      
      dismissViewControllerAnimated(false, completion: nil)
      
    } else {
      
      AppState.shared.currentState = .Feed
      tableView.reloadData()
    }
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == Constants.Segues.showProfile.rawValue {
      let backItem = UIBarButtonItem()
      backItem.title = "Back"
      navigationItem.backBarButtonItem = backItem
    }
  }
  
  //MARK: - BUTTONS
  
  @IBAction func profileButtonPressed(sender: UIButton) {
    performSegueWithIdentifier(Constants.Segues.showProfile.rawValue, sender: self)
  }
  
  
  //MARK: - TABLE VIEW
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print(DataService.ds.posts.count)
    
    return DataService.ds.posts.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if AppState.shared.currentState == .Feed {
      
      let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! PostCell
      
      let post = DataService.ds.posts[indexPath.row]
      
      var img: UIImage?
      var profileImg: UIImage?
      
      if let url = post.imageUrl {
        img = Cache.shared.imageCache.objectForKey(url) as? UIImage
        cell.showcaseImg.hidden = false
        cell.showcaseImg.image = UIImage(named: "DownloadingImageBackground")
        
      }
      
      if indicator.isAnimating() {
        self.indicator.stopAnimating()
      }
      
      if let profileImage = Cache.shared.profileImageCache.objectForKey(post.userKey) as? UIImage {
        profileImg = profileImage
      }
      
      cell.delegate = self
      cell.reloadTableDelegate = self
      cell.configureCell(post, img: img, profileImg: profileImg)
      
      return cell
    }
    return UITableViewCell()
  }
  
  
  //MARK - POST CELL DELEGATE
  
  func reloadTable() {
    
    tableView.reloadData()
    indicator.stopAnimating()
  }
  
  func showAlert(post: Post) {
    displayAlert(post)
  }
  
  func customCellCommentButtonPressed() {
    
    performSegueWithIdentifier(Constants.Segues.showComments.rawValue, sender: self)
  }
  
  
  //MARK: - ALERTS
  
  func displayAlert(post: Post) {
    
    guard let user = DataService.ds.currentUserKey else { guestAlert(); return }
    
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
      //post belongs to user
      if post.userKey == user {
        
        alert.addAction(UIAlertAction(title: "   Mark as Answered 😃", style: .Default, handler: { (action) in
          
          self.markAsAnsweredAlert(post)
          
        }))
        
        alert.addAction(UIAlertAction(title: "   Delete Post 👋", style: .Default, handler: { (action) in
          
          DataService.ds.deletePost(post)
          
        }))
        
      } else {
        
        alert.addAction(UIAlertAction(title: "Report", style: .Default, handler: { action in
          
          self.reportAlert(post)
          
        }))
        
        alert.addAction(UIAlertAction(title: "Block User", style: .Default, handler: { action in
          
          DataService.ds.blockUser(post)
          
        }))
        
      }
      
      alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
      
      self.presentViewController(alert, animated: true, completion: nil)
  }
  
  func reportAlert(post: Post) {
    
    let alert = UIAlertController(title: "Submit report", message: nil, preferredStyle: .Alert)
    
    alert.addTextFieldWithConfigurationHandler { (textField) in
      
      textField.placeholder = "Reason for report"
      textField.returnKeyType = .Default
    }
    
    alert.addAction(UIAlertAction(title: "Submit", style: .Default, handler: { (action) in
      
      DataService.ds.reportPost(post, reason: alert.textFields![0].text!)
      
    }))
    
    self.presentViewController(alert, animated: true, completion:  nil)
  }
  
  func markAsAnsweredAlert(post: Post) {
    
    let alert = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .Alert)
    
    alert.addTextFieldWithConfigurationHandler { (textField) in
      
      textField.placeholder = "Answer"
      textField.returnKeyType = .Default
    }
    
    alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { action in
      
      print(alert.textFields![0])
      if alert.textFields![0].text == "" {
        
        self.answerMissingAlert(post)
        
      } else {
        
        DataService.ds.markPostAsAnswered(post, answer: alert.textFields![0].text!)

      }
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
    
    self.presentViewController(alert, animated: true, completion:  nil)
  }
  
  func answerMissingAlert(post: Post) {
    
    let alert = UIAlertController(title: "Answer missing!", message: nil, preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
      
      self.markAsAnsweredAlert(post)
    }))
    
    self.presentViewController(alert, animated: true, completion:  nil)
    
  }

  
  func guestAlert() {
    
    let alert = UIAlertController(title: "Function unavailable 😕", message: "You must be logged in to comment", preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Login", style: .Default, handler: { action in
      
      self.dismissViewControllerAnimated(false, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  //MARK: - OTHER FUNCTIONS
  
  func checkLoggedIn() {
    
    if DataService.ds.posts.isEmpty {

      dismissViewControllerAnimated(true, completion: nil)
      
      let loginViewController: UIViewController!
      
      let storyboard = UIStoryboard(name: "Login", bundle: nil)
      loginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginVC")
      
      presentViewController(loginViewController, animated: true, completion: nil)
      
    }
  }
  
  func addIndicator() {
    indicator.startAnimating()
    indicator.hidesWhenStopped = true
    indicator.activityIndicatorViewStyle = .Gray
    indicator.frame = CGRectMake(self.view.frame.width / 2, self.view.frame.width / 2, 15.0, 15.0)
    
    self.view.addSubview(indicator)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}
