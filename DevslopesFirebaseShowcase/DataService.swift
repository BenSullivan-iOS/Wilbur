//
//  DataService.swift
//  Wilbur
//
//  Created by Ben Sullivan on 15/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()

struct DataStruct {
  
  var REF_POSTS = URL_BASE.child("posts")
  
  var REF_USER_CURRENT: FIRDatabaseReference {
    
    if let userKey = DataService.ds.currentUserKey {
      
      return URL_BASE.child("users").child(userKey)
      
    } else {
      
      return URL_BASE.child("users").child("guest")
      
    }
  }
}

class DataService: HelperFunctions {
  
  static let ds = DataService()
  
  weak var delegate: ReloadTableDelegate? = nil
  
  fileprivate init() {}
  
  fileprivate var _REF_BASE = URL_BASE
  fileprivate var _REF_POSTS = URL_BASE.child("posts")
  fileprivate var _REF_USERS = URL_BASE.child("users")
  fileprivate var _posts: [Post]!
  fileprivate var _answeredPosts: [Post]!
  fileprivate var _myPosts: [Post]!
  fileprivate var _currentUserKey: String?
  fileprivate var _usernames: [String: String]!
  fileprivate var count = 0

  var currentUserKey: String? {
    
    return UserDefaults.standard.value(forKey: Constants.KEY_UID) as? String ?? nil
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
  
  func deletePostAtIndex(_ index: Int) {
    
    _posts.remove(at: index)
  }
  
  func deleteAnsweredPostAtIndex(_ index: Int) {
    
    _answeredPosts.remove(at: index)
  }
  
  func deletePostsByBlockedUser(_ userKey: String) {
    
    _posts = _posts.filter { $0.userKey != userKey }
  }
  
  func createFirebaseUser(_ uid: String, user: [String:String]) {
    
    REF_USERS.child(uid).setValue(user)
    
  }
  
  func isAfterDate(_ startDate: Date, endDate: Date) -> Bool {
    
    let calendar = Calendar.current
    
    let components = (calendar as NSCalendar).components([.second],
                                         from: startDate,
                                         to: endDate.addingTimeInterval(86400),
                                         options: [])
    
    guard components.day != nil else { return false }
    
    if components.day! > 0 {
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
    
    userRef.observe(.value, with: { snapshot in
      
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
                
//                self.downloadProfileImage(i.0)
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
    
    userRef.observe(.value, with: { snapshot in
      
      self._usernames = [:]
      
      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots {
          
          if let userDict = snap.value as? [String: AnyObject] {
            
            if let name = userDict["username"] as? String {
//              print(name, snap.key)
              self._usernames[snap.key] = name
            }
          }
        }
      }
    })
  }
  
  func downloadPosts(_ blockedUsers: [String]) {
    
    DataService.ds.REF_POSTS.observe(.value, with: { snapshot in
      
      self._posts = []
      self._answeredPosts = []
      
      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots {
          
          if let postDict = snap.value as? [String: AnyObject] {
//            print(postDict)
            let key = snap.key
            let post = Post(postKey: key, dictionary: postDict)
            
            if post.answered == "" {
              
              if !blockedUsers.contains(post.userKey) {
                
                self._posts.append(post)
                self.downloadProfileImage(post.userKey)

              }
            } else {
              
              self._answeredPosts.append(post)
              //create array for answered table or just filter other array?
            }
          }
        }
        
        self._posts.sort(by: { (first, second) -> Bool in
          
          let df = DateFormatter()
          df.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
          
          if let firstDate = df.date(from: first.date), let secondDate = df.date(from: second.date) {
            
            return self.isAfterDate(firstDate, endDate: secondDate)
          }
          
          return true
        })
        
        //only download if not in cache already?
        
        if !self._posts.isEmpty {
          
          self.downloadImage(self.posts)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateComments"), object: self)
      }
    })
  }
  
  func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  
  func downloadImage(_ posts: [Post]) {
//    print("POSTS COUNT", count)
//    print(posts[count])
    
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
    
    guard Cache.shared.imageCache.object(forKey: imageLocation as AnyObject) as? UIImage == nil else {
//      print("image already downloaded")
      
      if self.count < posts.count - 1 {
        
        self.count += 1
        self.downloadImage(self.posts)
      } else {
        self.count = 0
      }
      return }
    
    let saveLocation = URL(fileURLWithPath: docsDirect() +  imageLocation)
    let storageRef: FIRStorageReference? = FIRStorage.storage().reference()
    
    guard let storage = storageRef else { return }
    
    let pathReference = storage.child(imageLocation)
    
    pathReference.write(toFile: saveLocation) { (URL, error) -> Void in
      
      guard let URL = URL, error == nil else { print("Data Service download error", error.debugDescription); return }
      
      if let data = try? Data(contentsOf: URL) {
        
        if let image = UIImage(data: data) {
          
          let newImage = self.resizeImage(image, newWidth: 414)
          
          Cache.shared.imageCache.setObject(newImage, forKey: imageLocation as AnyObject)
          
          
          if self.count < posts.count - 1 {
            if self.count == 1 {
              
            }
            self.count += 1
            
            self.downloadImage(self.posts)
          } else {
            self.delegate?.reloadTable()

            self.count = 0
          }
        }
      }
    }
  }
  
  func downloadProfileImage(_ uid: String) {

    if !ProfileImageTracker.imageLocations.contains(uid) {
      
      let saveLocation = URL(fileURLWithPath: docsDirect() + uid)
      let storageRef = FIRStorage.storage().reference()
      let pathReference = storageRef.child("profileImages").child(uid + ".jpg")
      
      pathReference.write(toFile: saveLocation) { (URL, error) -> Void in
        
        guard let URL = URL, error == nil else { print("Error - ", error.debugDescription); return }
        
        if let data = try? Data(contentsOf: URL) {
          
          if let image = UIImage(data: data) {
            
            Cache.shared.profileImageCache.setObject(image, forKey: (uid as AnyObject))

            ProfileImageTracker.imageLocations.insert(uid)
            print(uid)
            
          }
        }
      }
    }
  }
  
  func deletePost(_ post: Post) {
    
    let storageImageRef = FIRStorage.storage().reference()
    let postRef = DataService.ds.REF_POSTS.child(post.postKey) as FIRDatabaseReference!
    let userPostRef = DataService.ds.REF_USER_CURRENT.child("posts").child(post.postKey) as FIRDatabaseReference!
    
    let deleteMethod = storageImageRef.child("images").child(post.postKey + ".jpg")
    
    deleteMethod.delete(completion: { error in
      
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
          userPostRef?.removeValue()
          postRef?.removeValue()
          
          NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTables"), object: self)
          
          return
        }
      }
      
      for i in DataService.ds.answeredPosts.indices {
        
        if DataService.ds.answeredPosts[i].postKey == post.postKey {
          
          DataService.ds.deleteAnsweredPostAtIndex(i)
          userPostRef?.removeValue()
          postRef?.removeValue()
          
          NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTables"), object: self)
          
          return
        }
      }
    })
    
  }
  
  func blockUser(_ post: Post) {
    
    //Add blocked user to database
    let userRef = DataService.ds.REF_USER_CURRENT.child("blockedUsers").child(post.userKey)
    userRef.setValue(post.userKey)
    
    //Remove blocked user locally and update table
    for i in DataService.ds.posts {
      if i.postKey == post.postKey {
        
//        print(i.postKey, i.username)
        
        DataService.ds.deletePostsByBlockedUser(post.userKey)
        
      }
    }
    
    NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTables"), object: self)
    
    DataService.ds.downloadTableContent()
  }
  
  func markPostAsAnswered(_ post: Post, answer: String) {
    
    let postRef = DataService.ds.REF_POSTS.child(post.postKey).child("answered") as FIRDatabaseReference!
    
    postRef?.setValue(answer)
    
    for i in DataService.ds.posts.indices {
      
      if DataService.ds.posts[i].postKey == post.postKey {
        
        DataService.ds.deletePostAtIndex(i)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTables"), object: self)
        
        return
      }
    }
  }
  
  func reportPost(_ post: Post, reason: String) {
    
    let postRef = DataService.ds.REF_BASE.child("reportedPosts").child(post.postKey).child(DataService.ds.currentUserKey!) as FIRDatabaseReference!
    
    postRef?.setValue(reason)
    
    //Post needs to be marked as reported or deleted
    
  }
  
}
