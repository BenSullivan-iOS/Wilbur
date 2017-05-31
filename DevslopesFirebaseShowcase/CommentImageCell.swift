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
  
  func configureCell(_ selectedPost: Post?, downloadedImage: UIImage?) {
    
    guard let post = selectedPost else { return }
    
    if let image = downloadedImage {
      postImage.image = image
      postText.isHidden = true
      
      if post.postDescription != "" {
        
        postDescription.text = "\(post.postDescription) - \(post.username)"
        postDescription.font = UIFont.systemFont(ofSize: 16.0)
        
      } else {
        postDescription.isHidden = true
      }
      
    } else {
      postImage.isHidden = true
      postDescription.isHidden = true
      
      postText.text = "\(post.postDescription) - \(post.username)"
      postText.font = UIFont.systemFont(ofSize: 16.0)
    }
  }
}
