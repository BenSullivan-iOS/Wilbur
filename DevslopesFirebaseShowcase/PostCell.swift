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

class PostCell: UITableViewCell, NSCacheDelegate, CellConfiguration {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var showcaseImg: UIImageView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeImage: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var popText: UIButton!
  @IBOutlet weak var reportButton: UIButton!
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
    super.awakeFromNib()
    
    setupGestureRecognisers()
    reportButton.imageView?.contentMode = .scaleAspectFit
    Cache.shared.profileImageCache.delegate = self
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    showcaseImg.isHidden = false
    showcaseImg.image = nil
    profileImg.isHidden = false
    profileImg.image = nil
    
    downloadImageTask?.cancel()
    downloadProfileImageTask?.cancel()
  }
  
  
  //MARK: - SHOW ALERT
  
  @IBAction func reportbuttonPressed(_ sender: AnyObject) {
    
    delegate?.showAlert(post!)
  }
  
  
  //MARK: - CELL CONFIGURATION
  
  func refreshProfileImage() {
//    configureProfileImage(post, profileImg: profileImg)
  }
  
  func configureCell(_ post: Post, img: UIImage?, profileImg: UIImage?) {
    self._post = post
    self.likesLabel.text = "\(post.commentText.count)"
    self.username.text = post.username

    configureDescriptionText()
    
    configureImage(post, img: img)
    configureProfileImage(post, profileImg: profileImg)

    styleCommentButton()
    
  }
  
  func commentTapped() {
    
    if let post = post {
      
      let wrappedStruct = Wrap(post)
      
      var postInfo:[String: AnyObject] = ["post": wrappedStruct]
      
      if showcaseImg.isHidden == false {
        
        postInfo["image"] = showcaseImg.image
        postInfo["text"] = descriptionText
      }
      
      //Observed by PageContainer
      NotificationCenter.default.post(name: Notification.Name(rawValue: "segueToComments"), object: self, userInfo: postInfo)
      print("POSTING NOTIFICATION")
    }
    
  }
  
  func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
    ProfileImageTracker.imageLocations.removeAll()
  }
  
}
