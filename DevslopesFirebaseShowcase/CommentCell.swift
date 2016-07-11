//
//  CommentCell.swift
// Wilbur
//
//  Created by Ben Sullivan on 03/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
  
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var commentText: UITextView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    profileImage.layer.cornerRadius = profileImage.frame.width / 2
    profileImage.clipsToBounds = true
  }
  
  func configureCell(key: String, value: String) {
    
    commentText.text = key
    
    if let value = Cache.FeedVC.profileImageCache.objectForKey(value) as? UIImage {
      
      profileImage.image = value
    }
  }
}
