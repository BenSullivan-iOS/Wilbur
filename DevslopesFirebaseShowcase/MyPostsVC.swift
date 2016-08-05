//
//  Answered
//  Wilbur
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import FirebaseStorage

class MyPostsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MyPostsCellDelegate, ReloadTableDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  var selectedPost: Post? = nil
  var selectedPostImage: UIImage? = nil
    
  //MARK: - VC LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Posts"
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyPostsVC.reloadTable), name: "reloadTables", object: nil)
    
    self.tableView.estimatedRowHeight = 300
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    self.tableView.scrollsToTop = false
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  
  override func viewWillAppear(animated: Bool) {
    
    if AppState.shared.currentState == .PresentLoginFromComments {
      
      dismissViewControllerAnimated(false, completion: nil)
      
    } else {
      
      tableView.reloadData()
    }
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == Constants().sharedSegues.showProfile {
      let backItem = UIBarButtonItem()
      backItem.title = "Back"
      navigationItem.backBarButtonItem = backItem
    }
    
    if segue.identifier == "showComments" {
      
      if let dest = segue.destinationViewController as? CommentsVC {
        
        dest.post = selectedPost
        dest.postImage = selectedPostImage
        
        selectedPost = nil
        selectedPostImage = nil
      }
    }
  }
  
  //MARK: - BUTTONS
  
  @IBAction func profileButtonPressed(sender: UIButton) {
    performSegueWithIdentifier(Constants().sharedSegues.showProfile, sender: self)
  }
  
  
  //MARK: - TABLE VIEW
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return DataService.ds.myPosts.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
      if let cell = tableView.dequeueReusableCellWithIdentifier("myPostCell") as? MyPostsCell {
        
        print("indexPath = ", indexPath.row)
        
        let post = DataService.ds.myPosts[indexPath.row]
        
        var img: UIImage?
        var profileImg: UIImage?
        
        cell.showcaseImg.hidden = true
        cell.showcaseImg.image = nil
        cell.profileImg.hidden = true
        cell.profileImg.image = nil
        
        if let url = post.imageUrl {
          img = Cache.shared.imageCache.objectForKey(url) as? UIImage
          cell.showcaseImg.hidden = false
          cell.showcaseImg.image = UIImage(named: "DownloadingImageBackground")
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
  
  func showComments(post: Post, image: UIImage) {
    
    selectedPostImage = image
    selectedPost = post
    
    performSegueWithIdentifier("showComments", sender: self)
  }
  func reloadTable() {
    
    tableView.reloadData()
    
  }
  
  func showDeleteAlert(post: Post) {
    
    let alert = UIAlertController(title: "Are you sure you want to delete this post??", message: nil, preferredStyle: .ActionSheet)
    
    alert.addAction(UIAlertAction(title: "🤔...Yes please!", style: .Default, handler: { (action) in
        
        DataService.ds.deletePost(post)
        
      }))
    
    alert.addAction(UIAlertAction(title: "   No thanks 😁", style: .Cancel, handler: nil))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  //MARK: - ALERTS
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}
