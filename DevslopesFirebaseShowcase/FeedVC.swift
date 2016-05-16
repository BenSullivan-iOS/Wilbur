//
//  FeedVC.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  var imagePicker = UIImagePickerController()
  var posts = [Post]()
  
  static var imageCache = NSCache()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.estimatedRowHeight = 414
    
    imagePicker.delegate = self
        
    DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
      
      print(snapshot.value)
      self.posts = []

      if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
        
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
      
    } else {
      
      return PostCell()
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    let post = posts[indexPath.row]
    
    if post.imageUrl == nil {
      return 150
    } else {
      return tableView.estimatedRowHeight
    }
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
  }
}
