//
//  FeedVC.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  
  var posts = [Post]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
      
      print(snapshot.value)
      self.posts.removeAll()

      if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
        
        for snap in snapshots {
          
          
          if let postDict = snap.value as? [String: AnyObject] {
            
            let key = snap.key
            
            let post = Post(postKey: key, dictionary: postDict)
            
            self.posts.append(post)
            
          }
          print("SNAP: ", snap)
        }
        
        
      }
      
      self.tableView.reloadData()
      
    })
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("postCell")!
    let post = posts[indexPath.row]
    
    print(post.postDescription)
    
    return cell
  }
  
}
