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

class AnsweredCell: UITableViewCell, NSCacheDelegate, CellConfiguration {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var showcaseImg: UIImageView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeImage: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var popText: UIButton!
  @IBOutlet weak var reportButton: UIButton!
  @IBOutlet weak var answerText: ColoredLabel!
  @IBOutlet weak var descriptionText: UILabel!
  @IBOutlet weak var container: UIView!
  
  internal var downloadImageTask: FIRStorageDownloadTask? = nil
  internal var downloadProfileImageTask: FIRStorageDownloadTask? = nil
  internal var _post: Post?
  
  weak var delegate: PostCellDelegate? = nil
  weak var reloadTableDelegate: ReloadTableDelegate? = nil
  
  var post: Post? {
    
    get {
     return _post
    }
    set {
      self._post = newValue
    }
  }
  
  //MARK: - CELL LIFECYCLE
  
  override func awakeFromNib() {
    
    setupGestureRecognisers()
    reportButton.imageView?.contentMode = .ScaleAspectFit
    Cache.shared.profileImageCache.delegate = self
    
  }
  
  override func prepareForReuse() {
    downloadImageTask?.cancel()
    downloadProfileImageTask?.cancel()
  }
  
  
  //MARK: - SHOW ALERT
  
  @IBAction func reportbuttonPressed(sender: AnyObject) {
    
    delegate?.showAlert(post!)
  }
  
  //MARK: - CELL CONFIGURATION
  
  func configureCell(post: Post, img: UIImage?, profileImg: UIImage?) {
    
    self._post = post
    self.likesLabel.text = "\(post.commentText.count)"
    self.username.text = post.username
    self.answerText.text = post.answered
    
    configureDescriptionText()
    configureImage(post, img: img)
    configureProfileImage(post, profileImg: profileImg)
    
    styleCommentButton()
    
  }
  
  
  
  //CONFIGURATION FUNCTIONS
  
  func commentTapped() {
    
    if let post = post {
    
      let wrappedStruct = Wrap(post)
      
      var postInfo:[String: AnyObject] = ["post": wrappedStruct]
      
      if showcaseImg.hidden == false {
      
        postInfo["image"] = showcaseImg.image
        postInfo["text"] = descriptionText
      }
      
//      Observed by PageContainer
      NSNotificationCenter.defaultCenter().postNotificationName("segueToComments", object: self, userInfo: postInfo)
      print("POSTING NOTIFICATION")
    }
  }
  
  func cache(cache: NSCache, willEvictObject obj: AnyObject) {
    ProfileImageTracker.imageLocations.removeAll()
  }
  
}

