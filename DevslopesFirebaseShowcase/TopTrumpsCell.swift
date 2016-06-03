//
//  TopTrumpsCell.swift
//  Fart Club
//
//  Created by Ben Sullivan on 23/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class TopTrumpsCell: UITableViewCell {
  
  private var _post: Post?
  var likeRef: FIRDatabaseReference!
  var profileImage: FIRDatabaseReference!

  var request: Request?
  var post: Post? {
    return _post
  }
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var cellBackground: MaterialView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var pops: UILabel!
  
  override func awakeFromNib() {
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped))
    
    tap.numberOfTapsRequired = 1
    
  }
  
  override func drawRect(rect: CGRect) {
    
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
    profileImg.clipsToBounds = true
    
    //    showcaseImg.clipsToBounds = true
  }
  
  func configureCell(post: Post, img: UIImage?) {
    
    if post.likes == 1 {
      
      pops.text = "pop"
    }
    
    print("configure cell")
    
    if let like = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey) as? FIRDatabaseReference? {
      likeRef = like
    }
    
    //    likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
    
    
    self._post = post
    self.likesLabel.text = "\(post.likes)"
    self.username.text = post.username
    self.descriptionTextView.text = post.postDescription
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
    
    
    let currentUser = NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) as! String
    profileImage = DataService.ds.REF_USER_CURRENT.child("profileImage").child(currentUser)
    
    profileImage.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {
        
        //        self.profileImg.image =
        //        self.fakeButton.image = UIImage(named: "phoneyFart")
        
        
        
      } else {
        
        self.downloadProfileImage(snapshot.value as! String)
        
      }
      
    })
    
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
  
  func getDocumentsDirectory() -> NSURL {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    
    let url = NSURL(string: documentsDirectory)!
    
    return url
  }
  
  func downloadProfileImage(imageLocation: String) {
    
    print("Download Image")
    let saveLocation = NSURL(fileURLWithPath: String(getDocumentsDirectory()) + "/" + imageLocation)
    
    let storageRef = FIRStorage.storage().reference()
    let pathReference = storageRef.child("profileImages").child(imageLocation + ".jpg")
    print("profile image path reference", pathReference)
    pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
      print("Write to file")
      guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
      
      print("SUCCESS - ")
      print(URL)
      print(saveLocation)
      
      let image = UIImage(data: NSData(contentsOfURL: URL)!)!
      
      self.profileImg.image = image
      
      //      FeedVC.imageCache.setObject(image, forKey: self.post!.imageUrl!)
    }
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