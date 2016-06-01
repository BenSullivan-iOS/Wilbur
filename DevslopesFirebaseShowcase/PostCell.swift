//
//  PostCell.swift
//  Fart Club
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import FDWaveformView

class PostCell: UITableViewCell {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var showcaseImg: UIImageView!
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeImage: UIImageView!
  @IBOutlet weak var username: UILabel!
  
  @IBOutlet weak var fakeButton: UIImageView!
  @IBOutlet weak var fakeLabel: UIButton!
  
  @IBAction func fakeOrRemoveButtonPressed(sender: UIButton) {
    
    if fakeLabel.titleLabel!.text == "REMOVE" {
    
      delegate?.showDeletePostAlert((post?.postKey)!)
    } else {
      markFartAsFake((post?.postKey)!)
      print("code to report fake fart here")
    }
    
  }
  
  
  var delegate: PostCellDelegate? = nil
  
  var likeRef: FIRDatabaseReference!
  
  var postRef: FIRDatabaseReference!

  private var _post: Post?
  
  var post: Post? {
    return _post
  }
  
  override func awakeFromNib() {
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped))
    
    tap.numberOfTapsRequired = 1
    
    likeImage.addGestureRecognizer(tap)
    likeImage.userInteractionEnabled = true
    
    
  }
  
  override func drawRect(rect: CGRect) {
    
    profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
    profileImg.clipsToBounds = true
    
    showcaseImg.clipsToBounds = true
  }
  
  func getDocumentsDirectory() -> NSURL {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    
    let url = NSURL(string: documentsDirectory)!
    
    return url
  }
  
  func downloadImage(imageLocation: String) {
    
    print("Download Image")
    let saveLocation = NSURL(fileURLWithPath: String(getDocumentsDirectory()) + "/" + imageLocation)
    
    let storageRef = FIRStorage.storage().reference()
    let pathReference = storageRef.child(imageLocation)
    
    pathReference.writeToFile(saveLocation) { (URL, error) -> Void in
      print("Write to file")
      guard let URL = URL where error == nil else { print("Error - ", error.debugDescription); return }
      
      print("SUCCESS - ")
      print(URL)
      print(saveLocation)
      
      let image = UIImage(data: NSData(contentsOfURL: URL)!)!
      
      self.showcaseImg.image = image
      
      FeedVC.imageCache.setObject(image, forKey: self.post!.imageUrl!)
    }
  }
  
  var downloadedImage = UIImage()
  
//  var waveFormView: FDWaveformView!
//  
//  func showWaveForm(path: NSURL) {
//    
//    self.waveFormView.audioURL = path
//    self.waveFormView.doesAllowScrubbing = false
//    self.waveFormView.alpha = 1
//    self.waveFormView.bounds = (self.imageView?.bounds)!
//  }
//  
//  func waveformViewDidRender(waveformView: FDWaveformView) {
//    self.waveFormView.alpha = 1
//  }
  
  func configureCell(post: Post, img: UIImage?) {
    
    showcaseImg.image = UIImage(named: "placeholder")
    fakeButton.image = nil
    fakeLabel.setTitle("", forState: .Normal)
    
    likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
    postRef = DataService.ds.REF_USER_CURRENT.child("posts").child(post.postKey)

    
    self._post = post
    self.descriptionText.text = post.postDescription
    self.likesLabel.text = "\(post.likes)"
    self.username.text = post.username
    
    let path = AudioControls.shared.getDocumentsDirectory()
    let stringPath = String(path) + "/" + post.audioURL
    let finalPath = NSURL(fileURLWithPath: stringPath)
    CreatePost.shared.downloadAudio(finalPath, postKey: post.postKey)
    
    //if an image has been passed in then it is cached so use it, otherwise download and cache
    
    if let imageUrl = post.imageUrl {
      
      
      if let img = img {
        
        self.showcaseImg.image = img
        
      } else {
        
        self.downloadImage(imageUrl)
        
      }
    } else {
      
      showcaseImg.image = UIImage(named: "placeholder")
    }
    
    postRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {
        
        self.fakeLabel.setTitle("FAKE!", forState: .Normal)
        self.fakeButton.image = UIImage(named: "phoneyFart")
        
      } else {
        
        self.fakeButton.image = UIImage(named: "trashIcon")
        self.fakeLabel.setTitle("REMOVE", forState: .Normal)
      }
      
    })

    likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {
        
        self.likeImage.image = UIImage(named: "heart-empty")
        
      } else {
        
        self.likeImage.image = UIImage(named: "popImageUnpopped2")
      }
      
      
    })
  }
  
  //change image displaying, then add one like or remove one like
  func likeTapped() {
    
    likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      //in firebase if there's no data in .value you will receive an NSNull not nil
      if let _ = snapshot.value as? NSNull {
        //we have not liked this specific post
        
        self.likeImage.image = UIImage(named: "popImageUnpopped2")
        self.post?.adjustLikes(true)
        self.likeRef.setValue(true)
        
      } else {
        
        self.likeImage.image = UIImage(named: "heart-empty")
        self.post?.adjustLikes(false)
        self.likeRef.removeValue()
        
      }
      
      
    })
    
  }
  

  
  func markFartAsFake(key: String) {
    
    let fakeRef = DataService.ds.REF_POSTS.child(key).child("fakeCount") as FIRDatabaseReference
    let deletePostRef = DataService.ds.REF_POSTS.child(key) as FIRDatabaseReference
    
    fakeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      print("value = ", snapshot.value)
      //in firebase if there's no data in .value you will receive an NSNull not nil
      if let _ = snapshot.value as? NSNull {
        //we have not liked this specific post
        
        fakeRef.setValue(1)
        print("set fakeRef to 1")
      } else {
        
        if snapshot.value as! Int > 4 {
          deletePostRef.removeValue()
          self.postRef.removeValue()
        } else {
          self.post?.adjustFakeCount(true)
        }
        
        
      }
      
      
    })
    
  }
  
  
}

