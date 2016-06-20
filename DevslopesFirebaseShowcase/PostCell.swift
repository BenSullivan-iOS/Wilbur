//
//  PostCell.swift
//  Fart Club
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var showcaseImg: UIImageView!
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeImage: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var pop: UILabel!
  @IBOutlet weak var popText: UIButton!
  
  static var delegate: PostCellDelegate? = nil
  var downloadedImage = UIImage()
  private var likeRef: FIRDatabaseReference!
  private var postRef: FIRDatabaseReference!
  private var profileImage: FIRDatabaseReference!
  private var _post: Post?
  
  var post: Post? {
    return _post
  }
  
  override func awakeFromNib() {
    setupGestureRecognisers()
  }
  
  override func drawRect(rect: CGRect) {
    
    styleProfileImage()
    showcaseImg.clipsToBounds = true //FIXME: - Is this needed?
  }
  
  //MARK: - CELL CONFIGURATION
  
  func configureCell(post: Post, img: UIImage?, profileImg: UIImage?) {
    
    likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
    postRef = DataService.ds.REF_USER_CURRENT.child("posts").child(post.postKey)
    
    configureLikeButton()
    configureLikesText(post)
    configureImage(post, img: img)
    configureProfileImage(post, profileImg: profileImg)
    downloadAudio(post)
  }
  
  func configureLikesText(post: Post) {
    
//    if post.likes == 1 {
//      pop.text = "reply"
//    } else {
//      pop.text = "replies"
//    }
  }
  
  func configureProfileImage(post: Post, profileImg: UIImage?) {
    
    self.profileImg.image = UIImage(named: "profile-placeholder")
    
    if let profileImg = profileImg {
      print("Setting image from cache")
      self.profileImg.image = profileImg
      
    } else {
      print("downloading profile image")
      downloadProfileImage(post.userKey)
    }
    
  }
  
  func configureImage(post: Post, img: UIImage?) {
    
    if let imageUrl = post.imageUrl {
      
      if let img = img {
        
        self.showcaseImg.image = img
        
      } else {
        
        self.downloadImage(imageUrl)
      }
    }
  }
  
  func downloadAudio(post: Post) {
    
    self._post = post
    self.descriptionText.text = post.postDescription
    self.likesLabel.text = "\(post.likes)"
    self.username.text = post.username
    
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
    
    let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + imageLocation)
    
    let storageRef = FIRStorage.storage().reference()
    let pathReference = storageRef.child("profileImages").child(imageLocation + ".jpg")
    
    pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
      
      guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
      
      let image = UIImage(data: NSData(contentsOfURL: URL)!)!
      
      self.profileImg.image = image
      
      Cache.FeedVC.profileImageCache.setObject(image, forKey: (self.post?.userKey)!)
    }
  }
  
  func likeTapped() {
    
    likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {
        
        self.likeImage.image = UIImage(named: "likeIcon")
        self.popText.setTitleColor(UIColor(colorLiteralRed: 244/255, green: 81/255, blue: 30/255, alpha: 1), forState: .Normal)
        self.post?.adjustLikes(true)
        self.likeRef.setValue(true)
        
      } else {
        
        self.likeImage.image = UIImage(named: "likeIconGrey")
        self.popText.setTitleColor(UIColor(colorLiteralRed: 169/255, green: 194/255, blue: 194/255, alpha: 1), forState: .Normal)
        
        self.post?.adjustLikes(false)
        self.likeRef.removeValue()
      }
    })
  }
  
  func markFartAsFake(key: String) {
    
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
      
      let image = UIImage(data: NSData(contentsOfURL: URL)!)!
      
      self.showcaseImg.image = image
      
      print(self.post!.imageUrl)
      
      //      Cache.FeedVC.imageCache.setObject(image, forKey: self.post!.imageUrl!)
      Cache.FeedVC.imageCache.setObject(image, forKey: imageLocation)
      
    }
  }
  
  func styleProfileImage() {
    
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
    profileImg.clipsToBounds = true
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

