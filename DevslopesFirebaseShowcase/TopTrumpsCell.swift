//
//  TopTrumpsCell.swift
//  Wilbur
//
//  Created by Ben Sullivan on 23/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase

class TopTrumpsCell: UITableViewCell {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var cellBackground: MaterialView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var pops: UILabel!
  
  private var _post: Post?
  private var likeRef: FIRDatabaseReference!
  private var profileImage: FIRDatabaseReference!
  
  var post: Post? {
    return _post
  }
  
  override func awakeFromNib() {
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped))
    tap.numberOfTapsRequired = 1
  }
  
  func configureCell(post: Post, img: UIImage?, profileImg: UIImage?) {
    
    if post.likes == 1 {
      
      pops.text = "pop"
    }
    
    if let like = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey) as? FIRDatabaseReference? {
      likeRef = like
    }
    
    self._post = post
    self.likesLabel.text = "\(post.likes)"
    self.username.text = post.username
    self.descriptionTextView.text = post.postDescription
    
    self.profileImg.image = UIImage(named: "profile-placeholder")
    
    if let profileImg = profileImg {
      self.profileImg.image = profileImg
      
    } else {
      downloadProfileImage(post.userKey)
    }
  }
  
  
  func downloadProfileImage(imageLocation: String) {
    
    let saveLocation = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/" + imageLocation)
    
    let storageRef = FIRStorage.storage().reference()
    let pathReference = storageRef.child("profileImages").child(imageLocation + ".jpg")
    
    pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
      
      guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
      
      if let data = NSData(contentsOfURL: URL) {
        
        if let image = UIImage(data: data) {
          
          self.profileImg.image = image
          
          if let userKey = self.post?.userKey {
            
            Cache.FeedVC.profileImageCache.setObject(image, forKey: userKey)
          }
        }
      }
    }
  }
  
  override func drawRect(rect: CGRect) {
    
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
    profileImg.clipsToBounds = true
  }
  
  func likeTapped() {
    
    likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {
        
        self.post?.adjustLikes(true)
        self.likeRef.setValue(true)
        
      } else {
        
        self.post?.adjustLikes(false)
        self.likeRef.removeValue()
      }
    })
  }
}