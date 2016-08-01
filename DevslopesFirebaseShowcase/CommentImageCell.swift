//
//  CommentImageCell.swift
//  Wilbur
//
//  Created by Ben Sullivan on 03/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class CommentImageCell: UITableViewCell {
  
  @IBOutlet weak var postImage: UIImageView!
  @IBOutlet weak var postText: UITextView!
  @IBOutlet weak var postDescription: UITextView!
  
  func configureCell(selectedPost: Post?, downloadedImage: UIImage?) {
    
    guard let post = selectedPost else { return }
    
    if let image = downloadedImage {
      postImage.image = image
      postText.hidden = true
      
      if post.postDescription != "" {
        
        postDescription.text = "\(post.postDescription) - \(post.username)"
        postDescription.font = UIFont.systemFontOfSize(16.0)
        
      } else {
        postDescription.hidden = true
      }
      
    } else {
      postImage.hidden = true
      postDescription.hidden = true
      
      postText.text = "\(post.postDescription) - \(post.username)"
      postText.font = UIFont.systemFontOfSize(16.0)
    }
  }
}
