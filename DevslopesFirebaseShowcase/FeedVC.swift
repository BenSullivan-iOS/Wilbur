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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    record()
    
    ////////////
    let button: UIButton = UIButton(type: .Custom)
    button.setImage(UIImage(named: "profileFartWhite"), forState: .Normal)
    button.addTarget(self, action: #selector(FeedVC.showProfilePressed), forControlEvents: .TouchUpInside)
    button.frame = CGRectMake(0, 0, 30, 30)
    button.contentMode = .ScaleAspectFill
    
    let barButton = UIBarButtonItem(customView: button)
    self.navigationItem.rightBarButtonItem = barButton
    
    let leftButton: UIButton = UIButton(type: .Custom)
    leftButton.setImage(UIImage(named: "micIconThin"), forState: .Normal)
//    leftButton.addTarget(self, action: #selector(FeedVC.showProfilePressed), forControlEvents: .TouchUpInside)
        leftButton.addTarget(self, action: #selector(FeedVC.recordTapped), forControlEvents: .TouchUpInside)

    leftButton.frame = CGRectMake(0, 0, 30, 30)
    leftButton.contentMode = .ScaleAspectFill
    
    let leftBarButton = UIBarButtonItem(customView: leftButton)
    self.navigationItem.leftBarButtonItem = leftBarButton

        
    self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "FightThis", size: 40)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
//    
//    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
//    
//    self.navigationBar.barStyle = UIBarStyle.Black
//    self.navigationBar.tintColor = UIColor.whiteColor()
    
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
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return posts.count + 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.row > 0 {
      
    if let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as? PostCell {
    
      cell.request?.cancel()

      let post = posts[indexPath.row - 1]

      var img: UIImage?
      
      if let url = post.imageUrl {
        print("in the cache init")
        img = FeedVC.imageCache.objectForKey(url) as? UIImage
      }
      
      cell.configureCell(post, img: img)

      return cell
      
    } else {
      
      return PostCell()
    }
    
  }
    
    let cell = tableView.dequeueReusableCellWithIdentifier("uploadCell")!
    
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    if indexPath.row > 0 {
    let post = posts[indexPath.row - 1]
    
    if post.imageUrl == nil {
      return 150
    } else {
      return tableView.estimatedRowHeight
    }
    }
    
    return 66
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
  
  
  func showProfilePressed() {
    print("pressed")
    performSegueWithIdentifier(Constants.sharedSegues.showProfile, sender: self)
  
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == Constants.sharedSegues.showProfile {
    let backItem = UIBarButtonItem()
    backItem.title = "Back"
    navigationItem.backBarButtonItem = backItem
    }
  }
  
  var recordButton: UIButton!
  
  var recordingSession: AVAudioSession!
  var audioRecorder: AVAudioRecorder!
  
  var player = AVAudioPlayer()
}

extension FeedVC: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
  
  func record() {
    
    recordingSession = AVAudioSession.sharedInstance()
    
    do {
      try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
      try recordingSession.setActive(true)
      recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
        dispatch_async(dispatch_get_main_queue()) {
          if allowed {
            self.loadRecordingUI()
          } else {
            // failed to record!
          }
        }
      }
    } catch {
      // failed to record!
    }
  }
  
  func loadRecordingUI() {
    recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 128, height: 64))
    recordButton.setTitle("Tap to Record", forState: .Normal)
    recordButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
    recordButton.addTarget(self, action: #selector(FeedVC.recordTapped), forControlEvents: .TouchUpInside)
    view.addSubview(recordButton)
  }
  
  func startRecording() {
    
    let audioURL = getDocumentsDirectory().URLByAppendingPathComponent("recording.m4a") //stringByAppendingPathComponent("recording.m4a")
//    let audioURL = NSURL(fileURLWithPath: audioFilename)
    
    let settings = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: 12000.0,
      AVNumberOfChannelsKey: 1 as NSNumber,
      AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
    ]
    
    do {
      audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
      audioRecorder.delegate = self
      audioRecorder.record()
      
      recordButton.setTitle("Tap to Stop", forState: .Normal)
    } catch {
      finishRecording(success: false)
    }
  }
  
  func finishRecording(success success: Bool) {
    audioRecorder.stop()
    audioRecorder = nil
    
    if success {
      recordButton.setTitle("Tap to Re-record", forState: .Normal)
      
      play()
    } else {
      recordButton.setTitle("Tap to Record", forState: .Normal)
      // recording failed :(
    }
  }
  
  func recordTapped() {
    if audioRecorder == nil {
      startRecording()
    } else {
      finishRecording(success: true)
    }
  }
  
  func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
    if !flag {
      finishRecording(success: false)
    }
  }
  
  func getDocumentsDirectory() -> NSURL {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    
    let url = NSURL(string: documentsDirectory)!
    return url
  }

  func play() {
    
//    let path = NSBundle.mainBundle().pathForResource("recording", ofType: "m4a")
//    let fileURL = NSURL(fileURLWithPath: path!)
    
    let fileURL = getDocumentsDirectory().URLByAppendingPathComponent("recording.m4a")

    do {
      
      player = try AVAudioPlayer(contentsOfURL: fileURL)
      player.prepareToPlay()
      player.volume = 1
      player.delegate = self
      player.play()
      
    } catch {
      print("error playing file")
    }

  }
  
  
}



