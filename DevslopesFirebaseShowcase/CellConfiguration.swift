//
//  CellConfiguration.swift
//  Wildlife
//
//  Created by Ben Sullivan on 05/08/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

protocol CellConfiguration: class, HelperFunctions  {
  
  weak var reloadTableDelegate: ReloadTableDelegate? { get set }

  var post: Post? { get set }
  var _post: Post? { get set }
    
  func configureDescriptionText()
  var descriptionText: UILabel! { get }
  
  var profileImg: UIImageView! { get }
  var downloadProfileImageTask: FIRStorageDownloadTask? { get set }
  func downloadProfileImage(_ uid: String)
  func downloadProfileImageFromStorage(_ uid: String)
  
  var showcaseImg: UIImageView! { get }
  func configureImage(_ post: Post, img: UIImage?)
  
  var likeImage: UIImageView! { get }
  var popText: UIButton! { get }
  func styleCommentButton()
  
  var container: UIView! { get }
  
  func downloadImage(_ imageLocation: String)
  var downloadImageTask: FIRStorageDownloadTask? { get set }
  
  func commentTapped()
  
}

extension CellConfiguration {
  
  func configureDescriptionText() {
    
    guard let cellPost = post else { return }
    
    if cellPost.postDescription == "" {
      
//      self.descriptionText.hidden = true
      
    } else {
      
      self.descriptionText.isHidden = false
      self.descriptionText.text = cellPost.postDescription
      
      Cache.shared.labelCache.setObject(descriptionText, forKey: cellPost.postKey as AnyObject)
      
    }
  }
  
  func configureProfileImage(_ post: Post, profileImg: UIImage?) {
    
    if let profileImg = profileImg {
      DispatchQueue.main.async(execute: {

        self.profileImg.isHidden = false
        self.profileImg.image = profileImg
      })
      
    } else {
      
      self.profileImg.isHidden = false
      self.profileImg.image = UIImage(named: "profile-placeholder")
      self.downloadProfileImage(post.userKey)
    }
  }
  
  func configureImage(_ post: Post, img: UIImage?) {
    
    if let imageUrl = post.imageUrl {
      
      if let img = img {
        
        showcaseImg.isHidden = false
        showcaseImg.image = img
        
      } else {
        downloadImage(imageUrl)
      }
    } else {
      print(post.postDescription)
      showcaseImg.isHidden = true
    }
  }
  
  func styleCommentButton() {
    
    let highlightedColor = UIColor(colorLiteralRed: 42/255, green: 140/255, blue: 166/255, alpha: 1)
    let greyColor = UIColor(colorLiteralRed: 169/255, green: 194/255, blue: 194/255, alpha: 1)
    
    if let commentedOn = Cache.shared.commentedOnCache.object(forKey: post!.postKey as AnyObject) as? Bool {
      
      print("commentedOn", commentedOn)
      if commentedOn {
        self.likeImage.image = UIImage(named: "commentCounter")
        self.popText.setTitleColor(highlightedColor, for: UIControlState())
        
        
      } else {
        self.likeImage.image = UIImage(named: "commentCounterGrey")
        self.popText.setTitleColor(greyColor, for: UIControlState())
        
      }
      
    } else {
      print("Download commented on")
      
      let commentRef: FIRDatabaseReference? = DataService.ds.REF_USER_CURRENT.child("comments").child(post!.postKey)
      
      if let commentRef = commentRef {
        
        commentRef.observeSingleEvent(of: .value, with: { snapshot in
          
          if let _ = snapshot.value as? NSNull {
            
            self.likeImage.image = UIImage(named: "commentCounterGrey")
            self.popText.setTitleColor(greyColor, for: UIControlState())
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
              Cache.shared.commentedOnCache.setObject(false as AnyObject, forKey: (self.post?.postKey)! as AnyObject)
            }
          } else {
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak weakSelf = self] in
              
              weakSelf?.post?.wasCommentedOn(true)
              Cache.shared.commentedOnCache.setObject(true as AnyObject, forKey: (self.post?.postKey)! as AnyObject)
            }
            self.likeImage.image = UIImage(named: "commentCounter")
            self.popText.setTitleColor(highlightedColor, for: UIControlState())
          }
        })
        
      }
      
    }
    
  }
  
  func setupGestureRecognisers() {
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.commentTapped))
    
    tap.numberOfTapsRequired = 1
    
    likeImage.addGestureRecognizer(tap)
    likeImage.isUserInteractionEnabled = true
    
    let containerTap = UITapGestureRecognizer(target: self, action: #selector(PostCell.commentTapped))
    
    containerTap.numberOfTapsRequired = 1
    
    container.addGestureRecognizer(tap)
    container.isUserInteractionEnabled = true
    
    let likeTextTap = UITapGestureRecognizer(target: self, action: #selector(PostCell.commentTapped))
    
    likeTextTap.numberOfTapsRequired = 1
    
    popText.addGestureRecognizer(likeTextTap)
    popText.isUserInteractionEnabled = true
  }
}
