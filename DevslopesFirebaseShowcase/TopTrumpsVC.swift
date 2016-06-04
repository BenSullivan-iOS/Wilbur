//
//  TopTrumpsVC.swift
//  Fart Club
//
//  Created by Ben Sullivan on 23/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase

class TopTrumpsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var posts = [Post]()
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.scrollsToTop = false
    
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
        
        self.posts.sortInPlace({ (first, second) -> Bool in
          
          return first.likes > second.likes
        })
        
        self.tableView.reloadData()
        
      }
      
    })
  }
  
  override func viewDidAppear(animated: Bool) {
    
    AppState.shared.currentState = .TopTrumps
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! TopTrumpsCell
    
    let path = AudioControls.shared.getDocumentsDirectory()
    let stringPath = String(path) + "/" + posts[indexPath.row].audioURL
    let finalPath = NSURL(fileURLWithPath: stringPath)
    CreatePost.shared.downloadAudio(finalPath, postKey: posts[indexPath.row].postKey)
    
    
    if cell.cellBackground.backgroundColor == .whiteColor() {
      
      //      cell.cellBackground.backgroundColor = UIColor(colorLiteralRed: 240/255, green: 250/255, blue: 255/255, alpha: 1)
      
    } else {
      
      //      cell.cellBackground.backgroundColor = .whiteColor()
    }
    
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCellWithIdentifier("topTrumpsCell") as? TopTrumpsCell {
      
      let post = posts[indexPath.row]
      
      var img: UIImage?
      var profileImg: UIImage?
      
      if let url = post.imageUrl {
        print("in the cache init")
        img = Cache.FeedVC.imageCache.objectForKey(url) as? UIImage
      }
      
      if let profileImage = Cache.FeedVC.profileImageCache.objectForKey(post.userKey) as? UIImage {
        print("profile image in the cache init", profileImage)
        profileImg = profileImage
      }
      
      cell.configureCell(post, img: img, profileImg: profileImg)
      
      return cell
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier("topTrumpsCell")!
    
    return cell
  }
  
}
