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
  private var _answeredPosts: [Post]!
  private var _myPosts: [Post]!
  private var _currentUserKey: String?
  private var _usernames: [String: String]!
  
  var currentUserKey: String? {
    
    return NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) as? String ?? nil
  }
  
  var usernames: [String: String] {
    return _usernames
  }


  var posts: [Post] {
    
    if let postArray = _posts {
      return postArray
    }
    return [Post]()
    
  }
  
  var answeredPosts: [Post] {
    
    if let postArray = _answeredPosts {
      return postArray
    }
    return [Post]()
    
  }
  
  var myPosts: [Post] {
    
    let allPosts = _posts + _answeredPosts
    
    let posts = allPosts.filter { $0.userKey == DataService.ds.currentUserKey }
    
    return posts
    
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
    
    if let userKey = DataService.ds.currentUserKey {
      
      return URL_BASE.child("users").child(userKey)
    } else {
      
      return URL_BASE.child("users").child("guest")

    }
  }
  
  func deletePostAtIndex(index: Int) {
    
    _posts.removeAtIndex(index)
  }
  
  func deleteAnsweredPostAtIndex(index: Int) {
    
    _answeredPosts.removeAtIndex(index)
  }
  
  func deletePostsByBlockedUser(userKey: String) {
    
    _posts = _posts.filter { $0.userKey != userKey }
  }
  
  func createFirebaseUser(uid: String, user: [String:String]) {
    
    REF_USERS.child(uid).setValue(user)
    
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
    
    downloadUsernamesForComments()
    
    var blockedUsers = [String]()
    
    guard DataService.ds.currentUserKey != nil else {
      downloadPosts([""]); return }
    
    let userRef = DataService.ds.REF_USER_CURRENT

    userRef.observeEventType(.Value, withBlock: { snapshot in
      
      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots {
          
          if let userDict = snap.value as? [String: AnyObject] {
            
            if snap.key == "blockedUsers" {
              
              for i in userDict {
                
                blockedUsers.append(i.0)
              }
            }
            
            if snap.key == "profileImage" {

              for i in userDict {
                
                self.downloadProfileImage(i.0)
              }
            }
            
          }
        }
        self.downloadPosts(blockedUsers)
      }
    })
    
  }
  
  func downloadUsernamesForComments() {
    
    let userRef = DataService.ds.REF_USERS
    
    userRef.observeEventType(.Value, withBlock: { snapshot in
      
      self._usernames = [:]
      
      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots {
          
          if let userDict = snap.value as? [String: AnyObject] {
            
            let name = userDict["username"] as! String
            print(name, snap.key)
            self._usernames[snap.key] = name
            
          }
        }
      }
    })
  }
  
  func downloadPosts(blockedUsers: [String]) {
    
    DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
      
      self._posts = []
      self._answeredPosts = []
      
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
              
              self._answeredPosts.append(post)
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
    
    pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
      
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
  
  func downloadProfileImage(imageLocation: String) {
    
    if !ProfileImageTracker.imageLocations.contains(imageLocation) {
      
      let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + imageLocation)
      let storageRef = FIRStorage.storage().reference()
      let pathReference = storageRef.child("profileImages").child(imageLocation + ".jpg")
      
      pathReference.writeToFile(saveLocation) { (URL, error) -> Void in

        guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
        
        if let data = NSData(contentsOfURL: URL) {
          
          if let image = UIImage(data: data) {
            
            Cache.FeedVC.profileImageCache.setObject(image, forKey: (imageLocation))
            ProfileImageTracker.imageLocations.insert(imageLocation)
            
          }
        }
      }
    }
  }
  
  func deletePost(post: Post) {
    
    let storageImageRef = FIRStorage.storage().reference()
    let postRef = DataService.ds.REF_POSTS.child(post.postKey) as FIRDatabaseReference!
    let userPostRef = DataService.ds.REF_USER_CURRENT.child("posts").child(post.postKey) as FIRDatabaseReference!
    
    let deleteMethod = storageImageRef.child("images").child(post.postKey + ".jpg")
    
    deleteMethod.deleteWithCompletion({ error in
      
      guard error == nil else { print("delete error", error.debugDescription)
        
//        DataService.ds.deletePostAtIndex(i)
//        userPostRef.removeValue()
//        postRef.removeValue()
//        
//        NSNotificationCenter.defaultCenter().postNotificationName("reloadTables", object: self)
        
        return }
      
      print("storage image removed")
      
      for i in DataService.ds.posts.indices {
        
        if DataService.ds.posts[i].postKey == post.postKey {
          
          DataService.ds.deletePostAtIndex(i)
          userPostRef.removeValue()
          postRef.removeValue()
          
          NSNotificationCenter.defaultCenter().postNotificationName("reloadTables", object: self)
          
          return
        }
      }
      
      for i in DataService.ds.answeredPosts.indices {
        
        if DataService.ds.answeredPosts[i].postKey == post.postKey {
          
          DataService.ds.deleteAnsweredPostAtIndex(i)
          userPostRef.removeValue()
          postRef.removeValue()
          
          NSNotificationCenter.defaultCenter().postNotificationName("reloadTables", object: self)
          
          return
        }
      }
    })
  
  }
  
  func blockUser(post: Post) {
    
    //Add blocked user to database
    let userRef = DataService.ds.REF_USER_CURRENT.child("blockedUsers").child(post.userKey)
    userRef.setValue(post.userKey)
    
    //Remove blocked user locally and update table
    for i in DataService.ds.posts {
      if i.postKey == post.postKey {
        
        print(i.postKey, i.username)
        
        DataService.ds.deletePostsByBlockedUser(post.userKey)
        
      }
    }
    
    NSNotificationCenter.defaultCenter().postNotificationName("reloadTables", object: self)
    
    DataService.ds.downloadTableContent()
  }

  func markPostAsAnswered(post: Post) {
    
    let postRef = DataService.ds.REF_POSTS.child(post.postKey).child("answered") as FIRDatabaseReference!
    
    postRef.setValue(true)
  }
  
  func reportPost(post: Post, reason: String) {
    
    let postRef = DataService.ds.REF_BASE.child("reportedPosts").child(post.postKey).child(DataService.ds.currentUserKey!) as FIRDatabaseReference!
    
    postRef.setValue(reason)
    
    //Post needs to be marked as reported or deleted

  }

}