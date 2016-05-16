//
//  PostCell.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

  @IBOutlet weak var profileImg: UIImageView!
  
  @IBOutlet weak var showcaseImg: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
      
  }
  
  override func drawRect(rect: CGRect) {
    
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
    profileImg.clipsToBounds = true
    
    showcaseImg.clipsToBounds = true
  }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
