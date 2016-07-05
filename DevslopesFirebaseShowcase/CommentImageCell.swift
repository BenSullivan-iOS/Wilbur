//
//  CommentImageCell.swift
//  Wildlife
//
//  Created by Ben Sullivan on 03/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class CommentImageCell: UITableViewCell {
  
  @IBOutlet weak var postImage: UIImageView!
  @IBOutlet weak var postText: UITextView!
  @IBOutlet weak var postDescription: UITextView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
