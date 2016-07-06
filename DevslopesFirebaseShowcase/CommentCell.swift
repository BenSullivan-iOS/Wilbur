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
  
  func configureCell(post: Post) {
    
    let commentRef = DataService.ds.REF_USER_CURRENT.child("posts").child(post.postKey).child("comments")
    
    commentRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {
        
        
      } else {
        
             }
    })

    

  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
