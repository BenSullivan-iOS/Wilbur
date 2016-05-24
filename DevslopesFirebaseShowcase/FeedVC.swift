//
//  FeedVC.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AVFoundation

//class NavController: UIViewController {
//  
//  override func viewDidLoad() {
//    
//    self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "FightThis", size: 40)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
//
//  }
//}

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var imageSelectorImage: UIImageView!

  @IBOutlet weak var postField: MaterialTextField!
  @IBAction func selectImage(sender: UITapGestureRecognizer) {
    
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  var imagePicker = UIImagePickerController()
  var posts = [Post]()
  
  static var imageCache = NSCache()
  
  @IBOutlet weak var profileButton: UIButton!
  @IBOutlet weak var navBar: UINavigationBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //FIXME: - Add this back
//    record()
    
    ////////////
//    
//    let leftButton: UIButton = UIButton(type: .Custom)
//    leftButton.setImage(UIImage(named: "micIcon"), forState: .Normal)
//    leftButton.addTarget(self, action: #selector(FeedVC.recordTapped), forControlEvents: .TouchUpInside)

//    leftButton.frame = CGRectMake(0, 0, 30, 30)
//    leftButton.contentMode = .ScaleAspectFill
//    
//    let leftBarButton = UIBarButtonItem(customView: leftButton)
//    self.navigationItem.leftBarButtonItem = leftBarButton
    
    ////////////
    
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.estimatedRowHeight = 414
    
    imagePicker.delegate = self
        
    DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
      
      print(snapshot.value)
      self.posts = []

      if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
        
        for snap in snapshots {
          
          if let postDict = snap.value as? [String: AnyObject] {
            
            let key = snap.key
            
            let post = Post(postKey: key, dictionary: postDict)
            
            self.posts.append(post)
            
          }
          print("SNAP: ", snap)
        }
        
        self.tableView.reloadData()

      }
      
    })
  }
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("Selected")
  }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return posts.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as? PostCell {
    
      cell.request?.cancel()

      let post = posts[indexPath.row]

      var img: UIImage?
      
      if let url = post.imageUrl {
        print("in the cache init")
        img = FeedVC.imageCache.objectForKey(url) as? UIImage
      }
      
      cell.configureCell(post, img: img)

      return cell
  }
    
    let cell = tableView.dequeueReusableCellWithIdentifier("uploadCell")!
    
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    let post = posts[indexPath.row]
    
    if post.imageUrl == nil {
      return 150
    } else {
      return self.view.bounds.height - navBar.bounds.height - 20
    }
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
    imageSelectorImage.image = image
  }
  
  
  @IBAction func makePost(sender: AnyObject) {
    
    if let txt = postField.text where txt != "" {
      
      if let img = imageSelectorImage.image where imageSelectorImage.image != UIImage(named: "camera") {
        let urlStr = "https://post.imageshack.us/upload_api.php"
        let url = NSURL(string: urlStr)!
        
        let imageData = UIImageJPEGRepresentation(img, 0.2)!
        
        //Multi part form request
        
        let keyData = "23GLNQRU1a3692bd083188c27d289f6cf2e5382c".dataUsingEncoding(NSUTF8StringEncoding)!
        
        let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
        
        Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
          
          multipartFormData.appendBodyPart(data: imageData, name: "fileupload", fileName: "image", mimeType: "image/jpeg")
          
          multipartFormData.appendBodyPart(data: keyData, name: "key")
          multipartFormData.appendBodyPart(data: keyJSON, name: "format")
          
        }) { encodingResult in
          
          switch encodingResult {
            
          case .Success(let upload, _, _):
            
            upload.responseJSON { response in
              
              if let info = response.result.value as? [String : AnyObject] {
                
                if let links = info["links"] as? [String : AnyObject] {
                  
                  if let imgLink = links["image_link"] as? String {
                    
                    print("LINK: \(imgLink)")
                    
                    self.postToFirebase(imgLink)
                    
                  }
                  
                }
                
              }
              
            }
            
          case .Failure(let error):
            print(error)
            
          }
          
        }
        
      } else {
        
        print("no image")
        
        self.postToFirebase(nil)
      }
    }
  }
  
  func postToFirebase(imageUrl: String?) {
    
    var post: [String: AnyObject] = [ "description" : postField.text!, "likes": 0 ]
    
    
    if imageUrl != nil {
      post["imageUrl"] = imageUrl!
    }
    
    //generates new ID for URL
    let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
    
    //save to database
    firebasePost.setValue(post)
    
    postField.text = ""
    imageSelectorImage.image = UIImage(named: "camera")
    tableView.reloadData()

  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    print("preferred status bar")
    return .LightContent
  }
  
  @IBAction func profileButtonPressed(sender: UIButton) {
    performSegueWithIdentifier(Constants.sharedSegues.showProfile, sender: self)

  }
    
//  weak var VC2: AudioControlsVC
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == Constants.sharedSegues.showProfile {
    let backItem = UIBarButtonItem()
    backItem.title = "Back"
    navigationItem.backBarButtonItem = backItem
    }
    
//    if segue.identifier == "audioControls" {
//      
//      let dest = segue.destinationViewController as? AudioControlsVC
//      playingState()
//      
//      self.VC2 = dest
//      
//      let vc = segue.destinationViewController as! AudioControlsVC
//      vc.delegate = self
//    }
  }

//    VC2.delegate = self
  }

//class AudioControlsVC: UIViewController {
//  
//  var delegate: PlayingAudioDelegate?
//  
//  override func viewDidAppear(animated: Bool) {
//    
//    
//    
//  }
//  
//  //setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions:AVAudioSessionCategoryOptions.DefaultToSpeaker, error: nil)
//
//}

