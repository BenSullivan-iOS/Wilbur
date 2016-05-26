//
//  TopTrumpsVC.swift
//  DevslopesFirebaseShowcase
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
        
        self.tableView.reloadData()
        
      }
      
    })
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! TopTrumpsCell
    
    if cell.cellBackground.backgroundColor == .whiteColor() {
      
      cell.cellBackground.backgroundColor = UIColor(colorLiteralRed: 240/255, green: 250/255, blue: 255/255, alpha: 1)
      
    } else {
      
      cell.cellBackground.backgroundColor = .whiteColor()
    }
    
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCellWithIdentifier("topTrumpsCell") as? TopTrumpsCell {
      
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
    
    let cell = tableView.dequeueReusableCellWithIdentifier("topTrumpsCell")!
    
    return cell
  }
  
}
