//
//  PostCell.swift
//  Fart Club
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase

class ProfileImageTracker {
  
  static var imageLocations: Set = Set<String>()
  
}

class PostCell: UITableViewCell, UITextViewDelegate, NSCacheDelegate {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var showcaseImg: UIImageView!
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeImage: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var pop: UILabel!
  @IBOutlet weak var popText: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var delegate: PostCellDelegate? = nil
  private var downloadedImage = UIImage()
  private var likeRef: FIRDatabaseReference!
  private var postRef: FIRDatabaseReference!
  private var profileImage: FIRDatabaseReference!
  private var _post: Post?
  
  var post: Post? {
    return _post
  }
  
  override func awakeFromNib() {
    
    setupGestureRecognisers()
    
    descriptionText.delegate = self
    Cache.FeedVC.profileImageCache.delegate = self
    
  }
  
  override func drawRect(rect: CGRect) {
    
    styleProfileImage()
    showcaseImg.clipsToBounds = true //FIXME: - Is this needed?
  }
  
  //MARK: - CELL CONFIGURATION
  
  func configureCell(post: Post, img: UIImage?, profileImg: UIImage?) {
    
    likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
    postRef = DataService.ds.REF_USER_CURRENT.child("posts").child(post.postKey)
    
    activityIndicator.startAnimating()
    
    if post.postDescription == "" {
      
      self.descriptionText.hidden = true
      
    } else {
      
      self.descriptionText.hidden = false
      self.descriptionText.text = post.postDescription
      let fixedWidth = descriptionText.frame.size.width
      descriptionText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
      let newSize = descriptionText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
      var newFrame = descriptionText.frame
      newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
      descriptionText.frame = newFrame
      
    }
    self._post = post
    self.likesLabel.text = "\(post.likes)"
    self.username.text = post.username
    
    configureLikeButton()
    configureImage(post, img: img)
    if profileImg == nil {
      configureProfileImage(post, profileImg: profileImg)
    }
    downloadAudio(post)
  }
  
  
  
  func configureProfileImage(post: Post, profileImg: UIImage?) {
    print(post.userKey)
    
    self.profileImg.image = UIImage(named: "profile-placeholder")
    
    if let profileImg = profileImg {
      print("Setting profile image from cache")
      self.profileImg.image = profileImg
      //profileImg
      
    } else {
      print("downloading profile image")
      downloadProfileImage(post.userKey)
    }
    
  }
  
  
  
  func configureImage(post: Post, img: UIImage?) {
    
    if let imageUrl = post.imageUrl {
      showcaseImg.hidden = false
      
      if let img = img {
        
        self.showcaseImg.image = img
        self.activityIndicator.stopAnimating()
        
      } else {
        
        self.downloadImage(imageUrl)
      }
    } else {
      showcaseImg.hidden = true
      activityIndicator.stopAnimating()
      
    }
  }
  
  func downloadAudio(post: Post) {
    
    let path = HelperFunctions.getDocumentsDirectory()
    let stringPath = String(path) + "/" + post.audioURL
    let finalPath = NSURL(fileURLWithPath: stringPath)
    CreatePost.shared.downloadAudio(finalPath, postKey: post.postKey)
  }
  
  func configureLikeButton() {
    
    likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {
        
        self.likeImage.image = UIImage(named: "commentCounterGrey")
        self.popText.setTitleColor(UIColor(colorLiteralRed: 169/255, green: 194/255, blue: 194/255, alpha: 1), forState: .Normal)
        
      } else {
        
        self.likeImage.image = UIImage(named: "commentCounter")
        self.popText.setTitleColor(UIColor(colorLiteralRed: 42/255, green: 140/255, blue: 166/255, alpha: 1), forState: .Normal)
      }
    })
    
  }
  
  
  func downloadProfileImage(imageLocation: String) {
    
    print("PROFILE IMAGE LOCATION", imageLocation)
    print(ProfileImageTracker.imageLocations)
    
    if !ProfileImageTracker.imageLocations.contains(imageLocation) {
      print("Doesn't contain")
      
      let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + imageLocation)
      let storageRef = FIRStorage.storage().reference()
      let pathReference = storageRef.child("profileImages").child(imageLocation + ".jpg")
      
      pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
        print("downloading...")
        guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
        
        if let data = NSData(contentsOfURL: URL) {
          
          if let image = UIImage(data: data) {
            
            self.profileImg.image = image
            
            Cache.FeedVC.profileImageCache.setObject(image, forKey: (imageLocation))
            
          }
          
        }
        
        
      }
    } else {
      print("Post Cell, profile image already chached")
    }
    
    ProfileImageTracker.imageLocations.insert(imageLocation)
    
  }
  
  func likeTapped() {
    
    likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {
        
        self.likeImage.image = UIImage(named: "likeIcon")
        self.post?.adjustLikes(true)
        self.likeRef.setValue(true)
        
      } else {
        
        self.likeImage.image = UIImage(named: "likeIconGrey")
        self.popText.setTitleColor(UIColor(colorLiteralRed: 169/255, green: 194/255, blue: 194/255, alpha: 1), forState: .Normal)
        
        self.post?.adjustLikes(false)
        
        self.likeRef.removeValue()
      }
    })
    
    if let post = post {
      
      var postInfo:[String: AnyObject] = ["post": post]
      
      postInfo["image"] = showcaseImg.image
      
      NSNotificationCenter.defaultCenter().postNotificationName("comment", object: self, userInfo: postInfo)
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
  
  func downloadImage(imageLocation: String) {
    
    let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + imageLocation)
    
    let storageRef = FIRStorage.storage().reference()
    let pathReference = storageRef.child(imageLocation)
    
    pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
      
      guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
      
      if let data = NSData(contentsOfURL: URL) {
        
        if let image = UIImage(data: data) {
          
          self.showcaseImg.image = image
          Cache.FeedVC.imageCache.setObject(image, forKey: imageLocation)
          
          self.delegate?.reloadTable(image)
          
        }
      }
      
      self.activityIndicator.stopAnimating()
    }
  }
  
  func styleProfileImage() {
    
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
    profileImg.clipsToBounds = true
  }
  
  func cache(cache: NSCache, willEvictObject obj: AnyObject) {
    ProfileImageTracker.imageLocations.removeAll()
  }
  
  //MARK: - GESTURE RECOGNISERS
  
  func setupGestureRecognisers() {
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped))
    
    tap.numberOfTapsRequired = 1
    
    likeImage.addGestureRecognizer(tap)
    likeImage.userInteractionEnabled = true
    
    let likeTextTap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped))
    
    likeTextTap.numberOfTapsRequired = 1
    
    popText.addGestureRecognizer(likeTextTap)
    popText.userInteractionEnabled = true
  }
  
}

