//
//  PostCell.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {

  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var showcaseImg: UIImageView!
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var likesLabel: UILabel!
  
  var request: Request?

  private var _post: Post?
  
  var post: Post? {
    return _post
  }
  
  override func drawRect(rect: CGRect) {
    
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
    profileImg.clipsToBounds = true
    
    showcaseImg.clipsToBounds = true
  }

  func configureCell(post: Post, img: UIImage?) {
    
//    
//    //Clear existing image (because its old)
//    self.showcaseImg.image = nil
//    self._post = post
//    
////    if let desc = post.postDescription where post.postDescription != "" {
////      self.descriptionText.text = desc
////    } else {
////      self.descriptionText.hidden = true
////    }
//    
////    self.likesLbl.text = "\(post.likes)"
//    
//    if post.imageUrl != nil {
//      //Use the cached image if there is one, otherwise download the image
//      if img != nil {
//        showcaseImg.image = img!
//      } else {
//        //Must store the request so we can cancel it later if this cell is now out of the users view
//        request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
//          
//          if err == nil {
//            let img = UIImage(data: data!)!
//            self.showcaseImg.image = img
//            FeedVC.imageCache.setObject(img, forKey: self.post!.imageUrl!)
//          }
//        })
//      }
//      
//    } else {
//      self.showcaseImg.hidden = true
//    }
//    
//    
//    //can't set user image yet because we dont have user images set up yet
//    
//    
//  }
  
    self._post = post
    self.descriptionText.text = post.postDescription
    self.likesLabel.text = "\(post.likes)"
    print("image url:", post.imageUrl)
    if post.imageUrl != nil {
      print("here")
      if img != nil {
        print("then here")
        self.showcaseImg.image = img
        
      } else {
        
        print("ended up here")
        request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
          
          if err == nil {
            print("Image downloaded")
            let img = UIImage(data: data!)!
            self.showcaseImg.image = img
            FeedVC.imageCache.setObject(img, forKey: self.post!.imageUrl!)
          }
        })
      }
      
    } else {
      print("hidden the image")
      showcaseImg.hidden = true
    }
  }
    
  }

