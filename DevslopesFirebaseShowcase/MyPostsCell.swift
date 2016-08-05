//
//  PostCell.swift
//  Wilbur
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class MyPostsCell: UITableViewCell, NSCacheDelegate, CellConfiguration {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var showcaseImg: UIImageView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var popText: UIButton!
  @IBOutlet weak var container: MaterialView!
  @IBOutlet weak var descriptionText: UILabel!
  
  var likeImage: UIImageView!
  
  internal var downloadImageTask: FIRStorageDownloadTask? = nil
  internal var downloadProfileImageTask: FIRStorageDownloadTask? = nil
  internal var _post: Post?
  
  weak var delegate: MyPostsCellDelegate? = nil
  weak var reloadTableDelegate: ReloadTableDelegate? = nil

  var post: Post? {
    
    get {
      return _post
    }
    set {
      self._post = newValue
    }
  }
  
  override func awakeFromNib() {
    
    setupGestureRecognisers()
    Cache.shared.profileImageCache.delegate = self
  }
  
  override func prepareForReuse() {
    downloadImageTask?.cancel()
    downloadProfileImageTask?.cancel()
  }
  
  //MARK: - CELL CONFIGURATION
  
  func configureCell(post: Post, img: UIImage?, profileImg: UIImage?) {
    
    self._post = post
    self.likesLabel.text = "\(post.commentText.count)"
    self.username.text = post.username
    
    configureDescriptionText()
    configureImage(post, img: img)
    configureProfileImage(post, profileImg: profileImg)
    
    styleCommentButton()
  }
  
  func commentTapped() {
    delegate?.showComments(post!, image: showcaseImg.image!)
  }
  
  func cache(cache: NSCache, willEvictObject obj: AnyObject) {
    ProfileImageTracker.imageLocations.removeAll()
  }
  
  func styleCommentButton() {
    
//    let highlightedColor = UIColor(colorLiteralRed: 42/255, green: 140/255, blue: 166/255, alpha: 1)
//    let greyColor = UIColor(colorLiteralRed: 169/255, green: 194/255, blue: 194/255, alpha: 1)
//    
//    if let commentedOn = Cache.shared.commentedOnCache.objectForKey(post!.postKey) as? Bool {
//      
//      print("commentedOn", commentedOn)
//      if commentedOn {
//        self.popText.setTitleColor(highlightedColor, forState: .Normal)
//        
//        
//      } else {
//        self.popText.setTitleColor(greyColor, forState: .Normal)
//        
//      }
//      
//    } else {
//      print("Download commented on")
//      let commentRef: FIRDatabaseReference? = DataService.ds.REF_USER_CURRENT.child("comments").child(post!.postKey)
//
//      if let commentRef = commentRef {
//        
//        commentRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
//          
//          if let _ = snapshot.value as? NSNull {
//            
//            self.popText.setTitleColor(greyColor, forState: .Normal)
//            
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
//              Cache.shared.commentedOnCache.setObject(false, forKey: (self.post?.postKey)!)
//            }
//          } else {
//            
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
//              self.post?.wasCommentedOn(true)
//              Cache.shared.commentedOnCache.setObject(true, forKey: (self.post?.postKey)!)
//            }
//            self.popText.setTitleColor(highlightedColor, forState: .Normal)
//          }
//        })
//        
//      }
//      
//    }
    
  }

  
  func setupGestureRecognisers() {
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(MyPostsCell.commentTapped))
    
    tap.numberOfTapsRequired = 1
    
    let containerTap = UITapGestureRecognizer(target: self, action: #selector(MyPostsCell.commentTapped))
    
    containerTap.numberOfTapsRequired = 1
    
    container.addGestureRecognizer(tap)
    container.userInteractionEnabled = true
    
    
    let likeTextTap = UITapGestureRecognizer(target: self, action: #selector(MyPostsCell.showDeleteAlert))
    
    likeTextTap.numberOfTapsRequired = 1
    
    popText.addGestureRecognizer(likeTextTap)
    popText.userInteractionEnabled = true
  }
  
  func showDeleteAlert() {
    delegate?.showDeleteAlert(post!)
  }
  
}

