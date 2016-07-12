//
//  DataService.swift
// Wilbur
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()

class DataService {
  
  static let ds = DataService()
  
  weak var delegate: PostCellDelegate? = nil
    
  private init() {}
  
  private var _REF_BASE = URL_BASE
  private var _REF_POSTS = URL_BASE.child("posts")
  private var _REF_USERS = URL_BASE.child("users")
  private var _posts: [Post]!

  var posts: [Post] {
    
    if let postArray = _posts {
      return postArray
    }
    return [Post]()
    
  }
  var REF_BASE: FIRDatabaseReference {
    return _REF_BASE
  }
  
  var REF_POSTS: FIRDatabaseReference {
    return _REF_POSTS
  }
  
  var REF_USERS: FIRDatabaseReference {
    return _REF_USERS
  }
  
  var REF_USER_CURRENT: FIRDatabaseReference {
    
    let uid = NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) as! String
    
    let user = URL_BASE.child("users").child(uid)
    
    return user
  }
  
  func deletePostAtIndex(index: Int) {
    
    _posts.removeAtIndex(index)
  }
  
  func deletePostsByBlockedUser(userKey: String) {
    
    _posts = _posts.filter { $0.userKey != userKey }
  }
  
  func createFirebaseUser(uid: String, user: [String:String]) {
    
    REF_USERS.child(uid).setValue(user)
    
    print("Create firebase user")
    
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
  
  
  //MARK: - DOWNLOAD CONTENT
  
  func downloadTableContent() {
    
    var blockedUsers = [String]()
    
    let userRef = DataService.ds.REF_USER_CURRENT

    userRef.observeEventType(.Value, withBlock: { snapshot in
      
      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots {
          
          if let userDict = snap.value as? [String: AnyObject] {
            
            print(snap.key)
            
            if snap.key == "blockedUsers" {
              
              for i in userDict {
                
                blockedUsers.append(i.0)
                
              }
              
              print(userDict)
            
              
              print("Blocked users:", snap)

            }
          }
        }
        self.downloadPosts(blockedUsers)
      }
    })
  }
  
  func downloadPosts(blockedUsers: [String]) {
    
    DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
      
      self._posts = []
      
      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots {
          
          if let postDict = snap.value as? [String: AnyObject] {
            print(postDict)
            let key = snap.key
            let post = Post(postKey: key, dictionary: postDict)
            
            if !post.answered {
              
              if !blockedUsers.contains(post.userKey) {
                
                self._posts.append(post)

              }
              
              
            } else {
              
              //create array for answered table or just filter other array?
            }
          }
        }
        
        self._posts.sortInPlace({ (first, second) -> Bool in
          
          let df = NSDateFormatter()
          df.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
          
          if let firstDate = df.dateFromString(first.date), secondDate = df.dateFromString(second.date) {
            
            return self.isAfterDate(firstDate, endDate: secondDate)
          }
          
          return true
        })
        
        //only download if not in cache already?
        
        if !self._posts.isEmpty {
          
          self.downloadImage(self.posts)
        }
        NSNotificationCenter.defaultCenter().postNotificationName("updateComments", object: self)
      }
    })
  }
  
  var count = 0
  
  func downloadImage(posts: [Post]) {
    print("POSTS COUNT", count)
    print(posts[count])
    
    guard let imageLocation = posts[count].imageUrl else { print("no image");
      
      if self.count < posts.count - 1 {
        if self.count == 1 {
          self.delegate?.reloadTable()
        }
        self.count += 1
        self.downloadImage(self.posts)
      } else {
        self.count = 0
      }

      return }
    
    guard Cache.FeedVC.imageCache.objectForKey(imageLocation) as? UIImage == nil else {
      print("image already downloaded")
      
      if self.count < posts.count - 1 {
        
        self.count += 1
        self.downloadImage(self.posts)
      } else {
        self.count = 0
      }
      return }
    
    let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + imageLocation)
    let storageRef: FIRStorageReference? = FIRStorage.storage().reference()
    
    guard let storage = storageRef else { return }
    
    let pathReference = storage.child(imageLocation)
    
    let downloadImageTask = pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
      
      guard let URL = URL where error == nil else { print("Data Service download error", error.debugDescription); return }
      
      if let data = NSData(contentsOfURL: URL) {
        
        if let image = UIImage(data: data) {
          
          Cache.FeedVC.imageCache.setObject(image, forKey: imageLocation)
          
          if self.count < posts.count - 1 {
            if self.count == 1 {
              self.delegate?.reloadTable()
            }
            self.count += 1
            self.downloadImage(self.posts)
          } else {
            self.count = 0
          }
        }
      }
    }
  }
  
  

}