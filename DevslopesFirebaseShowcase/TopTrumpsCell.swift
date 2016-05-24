//
//  TopTrumpsCell.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 23/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class TopTrumpsCell: UITableViewCell {
  
  @IBOutlet weak var profileImg: UIImageView!
//  @IBOutlet weak var showcaseImg: UIImageView!
//  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var likesLabel: UILabel!
//  @IBOutlet weak var likeImage: UIImageView!

  var likeRef: Firebase!
  
  var request: Request?
  
  private var _post: Post?
  
  var post: Post? {
    return _post
  }
  
  override func awakeFromNib() {
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped))
    
    tap.numberOfTapsRequired = 1
    
//    likeImage.addGestureRecognizer(tap)
//    likeImage.userInteractionEnabled = true
  }
  
  override func drawRect(rect: CGRect) {
    
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
    profileImg.clipsToBounds = true
    
//    showcaseImg.clipsToBounds = true
  }
  
  func configureCell(post: Post, img: UIImage?) {
    
    print("configure cell")
    
    if let like = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey) {
      likeRef = like
    }
    
    //    likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
    
    
    self._post = post
//    self.descriptionText.text = post.postDescription
    self.likesLabel.text = "\(post.likes)"
    print("image url:", post.imageUrl)
    if post.imageUrl != nil {
      print("here")
      if img != nil {
        print("then here")
//        self.showcaseImg.image = img
        
      } else {
        
        print("ended up here")
        request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
          
          if err == nil {
            print("Image downloaded")
            let img = UIImage(data: data!)!
//            self.showcaseImg.image = img
            FeedVC.imageCache.setObject(img, forKey: self.post!.imageUrl!)
          }
        })
      }
//      showcaseImg.hidden = false
      
    } else {
      print("hidden the image")
//      showcaseImg.hidden = true
    }
    
    //    let likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
    //look for like once then toggle heart
    likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      
      //in firebase if there's no data in .value you will receive an NSNull not nil
      if let _ = snapshot.value as? NSNull {
        //we have not liked this specific post
        
//        self.likeImage.image = UIImage(named: "heart-empty")
        
        
      } else {
        
//        self.likeImage.image = UIImage(named: "heart-full")
      }
      
      
    })
  }
  //change image displaying, then add one like or remove one like
  func likeTapped() {
    
    likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      //in firebase if there's no data in .value you will receive an NSNull not nil
      if let _ = snapshot.value as? NSNull {
        //we have not liked this specific post
        
//        self.likeImage.image = UIImage(named: "popImageUnpopped")
        self.post?.adjustLikes(true)
        self.likeRef.setValue(true)
        
      } else {
        
//        self.likeImage.image = UIImage(named: "heart-empty")
        self.post?.adjustLikes(false)
        self.likeRef.removeValue()
        
      }
      
      
    })
    
  }
  
}