//
//  PostCell.swift
// Wilbur
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class AnsweredCell: UITableViewCell, NSCacheDelegate {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var showcaseImg: UIImageView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeImage: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var popText: UIButton!
  @IBOutlet weak var reportButton: UIButton!
  
  @IBOutlet weak var descriptionText: UILabel!
  
  private var commentRef: FIRDatabaseReference!
  private var postRef: FIRDatabaseReference!
  private var profileImage: FIRDatabaseReference!
  private var downloadImageTask: FIRStorageDownloadTask? = nil
  private var _post: Post?
  
  weak var delegate: PostCellDelegate? = nil
  
  var post: Post? {
    return _post
  }
  
  override func awakeFromNib() {
    
    setupGestureRecognisers()
    
    reportButton.imageView?.contentMode = .ScaleAspectFit
    
    Cache.FeedVC.profileImageCache.delegate = self
    
  }
  
  override func prepareForReuse() {
    downloadImageTask?.cancel()
  }
  
  
  //MARK: - SHOW ALERT
  
  @IBAction func reportbuttonPressed(sender: AnyObject) {
    
    delegate?.showAlert(post!)
  }
  
  //MARK: - CELL CONFIGURATION
  
  func configureCell(post: Post, img: UIImage?, profileImg: UIImage?) {
    
    commentRef = DataService.ds.REF_USER_CURRENT.child("comments").child(post.postKey)
    postRef = DataService.ds.REF_USER_CURRENT.child("posts").child(post.postKey)
    
    self._post = post
    self.likesLabel.text = "\(post.commentText.count)"
    self.username.text = post.username
    
    configureDescriptionText()
    configureImage(post, img: img)
    
    styleCommentButton()
    
    
    if profileImg == nil {
      configureProfileImage(post, profileImg: profileImg)
    }
    //    downloadAudio(post)
  }
  
  
  
  //CONFIGURATION FUNCTIONS
  
  func configureDescriptionText() {
    
    guard let cellPost = post else { return }
    
    if cellPost.postDescription == "" {
      
      self.descriptionText.hidden = true
      
    } else {
      
      self.descriptionText.hidden = false
      self.descriptionText.text = cellPost.postDescription
      
    }
  }
  
  func configureProfileImage(post: Post, profileImg: UIImage?) {
    
    self.profileImg.hidden = false
    self.profileImg.image = UIImage(named: "profile-placeholder")
    
    self.profileImg.image = UIImage(named: "profile-placeholder")
    
    if let profileImg = profileImg {
      
      self.profileImg.image = profileImg
      
    } else {
      self.downloadProfileImage(post.userKey)
    }
  }
  
  
  
  func configureImage(post: Post, img: UIImage?) {
    
    if let imageUrl = post.imageUrl {
      
      if let img = img {
        
        self.showcaseImg.hidden = false
        self.showcaseImg.image = img
        
      } else {
        
        self.downloadImage(imageUrl)
      }
    } else {
      print(post.postDescription)
      showcaseImg.hidden = true
    }
  }
  
  func downloadAudio(post: Post) {
    
    let path = HelperFunctions.getDocumentsDirectory()
    let stringPath = String(path) + "/" + post.audioURL
    let finalPath = NSURL(fileURLWithPath: stringPath)
    CreatePost.shared.downloadAudio(finalPath, postKey: post.postKey)
  }
  
  func styleCommentButton() {
    
    let highlightedColor = UIColor(colorLiteralRed: 42/255, green: 140/255, blue: 166/255, alpha: 1)
    let greyColor = UIColor(colorLiteralRed: 169/255, green: 194/255, blue: 194/255, alpha: 1)
    
    if let commentedOn = Cache.FeedVC.commentedOnCache.objectForKey(post!.postKey) as? Bool {
      
      print("commentedOn", commentedOn)
      if commentedOn {
        self.likeImage.image = UIImage(named: "commentCounter")
        self.popText.setTitleColor(highlightedColor, forState: .Normal)
        
        
      } else {
        self.likeImage.image = UIImage(named: "commentCounterGrey")
        self.popText.setTitleColor(greyColor, forState: .Normal)
        
      }
      
    } else {
      print("Download commented on")
      
      if let commentRef = commentRef {
        
        commentRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
          
          if let _ = snapshot.value as? NSNull {
            
            self.likeImage.image = UIImage(named: "commentCounterGrey")
            self.popText.setTitleColor(greyColor, forState: .Normal)
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
              Cache.FeedVC.commentedOnCache.setObject(false, forKey: (self.post?.postKey)!)
            }
          } else {
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
              self.post?.wasCommentedOn(true)
              Cache.FeedVC.commentedOnCache.setObject(true, forKey: (self.post?.postKey)!)
            }
            self.likeImage.image = UIImage(named: "commentCounter")
            self.popText.setTitleColor(highlightedColor, forState: .Normal)
          }
        })
        
      }
      
    }
    
  }
  
  
  
  
  func commentTapped() {
    
    if let post = post {
      
      var postInfo:[String: AnyObject] = ["post": post]
      
      if showcaseImg.hidden == false {
        
        postInfo["image"] = showcaseImg.image
      }
      
      //Observed by PageContainer
      NSNotificationCenter.defaultCenter().postNotificationName("segueToComments", object: self, userInfo: postInfo)
      print("POSTING NOTIFICATION")
    }
    
  }
  
  func report(key: String) {
    
    let fakeRef = DataService.ds.REF_POSTS.child(key).child("fakeCount") as FIRDatabaseReference
    let deletePostRef = DataService.ds.REF_POSTS.child(key) as FIRDatabaseReference
    
    fakeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {
        
        fakeRef.setValue(1)
        
      } else {
        
        if snapshot.value as! Int > 4 {
          deletePostRef.removeValue()
          self.postRef.removeValue()
        } else {
          self.post?.adjustFakeCount(true)
        }
      }
    })
  }
  
  //MARK: - DOWNLOAD IMAGE FUNCTIONS
  
  func downloadImage(imageLocation: String) {
    
    let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + imageLocation)
    
    let storageRef: FIRStorageReference? = FIRStorage.storage().reference()
    
    guard let storage = storageRef else { return }
    
    let pathReference = storage.child(imageLocation)
    
    downloadImageTask = pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
      
      guard let URL = URL where error == nil else { print("Download Image Error", error.debugDescription); return }
      
      if let data = NSData(contentsOfURL: URL) {
        
        if let image = UIImage(data: data) {
          
          self.showcaseImg.clipsToBounds = true
          self.showcaseImg.image = image
          self.showcaseImg.hidden = false
          
          Cache.FeedVC.imageCache.setObject(image, forKey: imageLocation)
          
          self.delegate?.reloadTable()
          
        }
      }
      
      //      self.activityIndicator.stopAnimating()
    }
  }
  
  func downloadProfileImage(imageLocation: String) {
    
    if !ProfileImageTracker.imageLocations.contains(imageLocation) {
      
      let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + imageLocation)
      let storageRef = FIRStorage.storage().reference()
      let pathReference = storageRef.child("profileImages").child(imageLocation + ".jpg")
      pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
        print("downloading...")
        guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
        
        if let data = NSData(contentsOfURL: URL) {
          
          if let image = UIImage(data: data) {
            
            Cache.FeedVC.profileImageCache.setObject(image, forKey: (imageLocation))
            ProfileImageTracker.imageLocations.insert(imageLocation)
            
            self.profileImg.image = image
          }
        }
      }
    } else {
      print("Post Cell, profile image already chached")
    }
  }
  
  func cache(cache: NSCache, willEvictObject obj: AnyObject) {
    ProfileImageTracker.imageLocations.removeAll()
  }
  
  //MARK: - GESTURE RECOGNISERS
  
  @IBOutlet weak var container: MaterialView!
  
  func setupGestureRecognisers() {
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.commentTapped))
    
    tap.numberOfTapsRequired = 1
    
    likeImage.addGestureRecognizer(tap)
    likeImage.userInteractionEnabled = true
    
    let containerTap = UITapGestureRecognizer(target: self, action: #selector(PostCell.commentTapped))
    
    containerTap.numberOfTapsRequired = 1
    
    container.addGestureRecognizer(tap)
    container.userInteractionEnabled = true
    
    
    let likeTextTap = UITapGestureRecognizer(target: self, action: #selector(PostCell.commentTapped))
    
    likeTextTap.numberOfTapsRequired = 1
    
    popText.addGestureRecognizer(likeTextTap)
    popText.userInteractionEnabled = true
  }
  
  
  
  
}

