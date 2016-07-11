//
//  CreatePostTest.swift
// Wilbur
//
//  Created by Ben Sullivan on 21/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage

protocol AudioPlayerDelegate {

  func audioRecorded()
}

class ImageTable: UITableViewCell {
  
  @IBOutlet weak var tableImage: UIImageView!
  
}

class CreatePostTest: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, PostButtonPressedDelegate, AudioPlayerDelegate {
  
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var cameraIcon: UIButton!
  @IBOutlet weak var micIcon: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var selectedImage: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  
  private var checkAudioRecorded = Bool()
  private let imagePicker = UIImagePickerController()
  private var selectedImagePath = NSURL?()
  private let tap = UITapGestureRecognizer()
  
  //MARK: - VIEW CONTROLLER LIFESCYCLE
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    
    scrollView.scrollEnabled = false
    
    tapGestureRecogniser()
    
    scrollView.delegate = self
    cameraIcon.imageView?.contentMode = .ScaleAspectFit
    micIcon.imageView?.contentMode = .ScaleAspectFit
    
    imagePicker.delegate = self
    
    descriptionText.delegate = self
    descriptionText.layer.cornerRadius = 3.0
    descriptionText.layer.borderWidth = 1.0
    descriptionText.layer.borderColor = UIColor(colorLiteralRed: 170/255, green: 170/255, blue: 170/255, alpha: 0.5).CGColor
  }

  
  override func viewWillAppear(animated: Bool) {
    
//    selectedImage.image = UIImage(named: "createPostPlaceholder")
//    
//    let height = AVMakeRectWithAspectRatioInsideRect(UIImage(named: "createPostPlaceholder")!.size, selectedImage.frame).height
//    tableView.rowHeight = height
//    tableView.reloadData()
    AppState.shared.currentState = .CreatingPost
    tap.enabled = true
    
//    selectedImage.image = UIImage(named: "createPostPlaceholder")

    
    
  }
  
  @IBAction func recordButtonPressed(sender: UIButton) {
    
    AudioControls.shared.recordTapped()
    
    
    
  }
  
  func audioRecorded() {
    //
  }
  
  
  
  func postButtonPressed() {
    print("Well done! Creating post etc...")
    postToFirebase()
  }
  
  override func viewWillDisappear(animated: Bool) {
    tap.enabled = false
  }
  
  //MARK: - BUTTONS
  
  @IBAction func takePhotoButtonPressed(sender: AnyObject) {
    
    guard NSUserDefaults.standardUserDefaults().valueForKey("username") != nil else { displayAlert("Function unavailable", message: "You must be logged in to post", state: .notLoggedIn); return }
    
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      
        imagePickerAlert()
      
    } else {
      presentViewController(imagePicker, animated: true, completion: nil)
    }
  }
  
  //MARK: - TABLE VIEW
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("imageCell") as! ImageTable
  
    if selectedImage.image != UIImage(named: "createPostPlaceholder") {
      cell.tableImage.image = selectedImage.image
      self.selectedImage.image = nil
    } else {
      
      cell.tableImage.image = nil

    }
    
    return cell
    
  }
  
  //MARK: - SETUP TEXTFIELD
  
  struct DescriptionText {
    static let defaultText = "Enter description, include as much detail as possible"
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    
    if descriptionText.text == DescriptionText.defaultText {
    descriptionText.text = ""
    }
    descriptionText.textColor = .grayColor()
  }
  
  func tapReceived() {
    
    self.view.endEditing(true)
  }
  
  func tapGestureRecogniser() {
    
    tap.addTarget(self, action: #selector(self.tapReceived))
    tap.numberOfTapsRequired = 1
    tap.enabled = true

    self.view.addGestureRecognizer(tap)
    
  }
  
  
  //MARK: - CAMERA FUNCTIONS
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

    scrollView.scrollEnabled = true
    
    dismissViewControllerAnimated(true, completion: nil)
    
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    selectedImage.image = image
    
    let saveDirectory = String(direct()) + "/images/tempImage.jpg"
    
    saveImage(image, path: saveDirectory)
    
    print("Did finish picking image - ", saveDirectory)
    let height = AVMakeRectWithAspectRatioInsideRect(image.size, selectedImage.frame).height

    tableView.rowHeight = height
    tableView.reloadData()
  }
  
  func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  func direct() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
  
  func saveImage (image: UIImage, path: String) -> Bool {
    
    let path2 = direct().stringByAppendingPathComponent("tempImage.jpg")
    print(path2)
//    let compressedImage = resizeImage(image, newWidth: 1536)
    let compressedImage = resizeImage(image, newWidth: 1000)

    let jpgImageData = UIImageJPEGRepresentation(compressedImage, 0.2)
    let result = jpgImageData!.writeToFile(path2, atomically: true)
    print(result)
    selectedImagePath = NSURL(fileURLWithPath: path2)
    
    return result
  }
  
  
  
  //MARK: - POST FUNCTION
  
    func postToFirebase() {
      
      guard selectedImage.image != UIImage(named: "createPostPlaceholder") else { displayAlert("🤔 Missing information", message: "Please add a photo", state: .noPhoto); return }
      
      guard let username = NSUserDefaults.standardUserDefaults().valueForKey("username") else { print("no username"); return }

      let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
  
      guard let userKey = NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) as? String else { print("no username key"); return }
      
      guard descriptionText != "" else { return }
      
      postingAlert()
  
      var post: [String: AnyObject] = [
  "description" : descriptionText.text!,
          "user": username,
          "date": String(NSDate()),
       "userKey": userKey
      ]
    
      
      //Save audio if available
      
      if let audioPath = NSURL(fileURLWithPath: String(direct()) + "/recording.m4a").path {
        
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(audioPath) {
          print("Audio available")
          
          let audioURL = NSURL(fileURLWithPath: String(direct()) + "/recording.m4a")
          
          CreatePost.shared.uploadAudio(audioURL, firebaseReference: firebasePost.key)
          
          post["audio"] = "audio/\(firebasePost.key).m4a"

        } else {
          print("Audio unavailable")
        }
      }
      
      
      //Save image if available
  
      if let imagePath = selectedImagePath {
  
        uploadImage(imagePath, firebaseReference: firebasePost.key)
        post["imageUrl"] = "images/\(firebasePost.key).jpg"
  
      } else {
        
        self.postedAlert()
   
        self.checkAudioRecorded = false
      }
  
      firebasePost.setValue(post)
  
      descriptionText.text = ""
      selectedImage.image = UIImage(named: "createPostPlaceholder")
      tableView.reloadData()
  
      savePostToUser(firebasePost.key)
    }
  
    func savePostToUser(postKey: String) {
  
      let firebasePost = DataService.ds.REF_USER_CURRENT.child("posts").child(postKey)
      firebasePost.setValue(postKey)
      
      let addDefaultText = DataService.ds.REF_POSTS.child(postKey).child("comments").child("placeholder")
      addDefaultText.setValue(1)
      
    }
  
  
    func uploadImage(localFile: NSURL, firebaseReference: String) {
  
      let storageRef = FIRStorage.storage().reference()
      let riversRef = storageRef.child("images/\(firebaseReference).jpg")
  
      riversRef.putFile(localFile, metadata: nil) { metadata, error in
        guard let metadata = metadata where error == nil else { print("Upload Image Error", error); return }

        print("success")
        print("metadata")
        
        self.postedAlert()
        
        self.selectedImagePath = nil
        
        NSNotificationCenter.defaultCenter().postNotificationName("imageSaved", object: self)
        
      }
    }

  //MARK: - ALERTS
  
  func imagePickerAlert() {
    
    let alert = UIAlertController(title: "Choose source type", message: "", preferredStyle: .ActionSheet)
    alert.popoverPresentationController?.sourceView = self.view
    
    alert.addAction(UIAlertAction(title: "Take photo 📷", style: .Default, handler: { action in
      
      self.imagePicker.sourceType = .Camera
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    
    alert.addAction(UIAlertAction(title: "Photo library 📱", style: .Default, handler: { action in
      
      self.imagePicker.sourceType = .PhotoLibrary
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel ", style: .Cancel, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  enum AlertState {
    case notLoggedIn
    case noPhoto
  }
  
  func displayAlert(title: String, message: String, state: AlertState) {

    self.view.endEditing(true)
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    switch state {
    case .noPhoto:
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      
    case .notLoggedIn:
      alert.addAction(UIAlertAction(title: "Login", style: .Default, handler: { action in
      
        self.dismissViewControllerAnimated(false, completion: nil)
      
      }))
      
      alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

      
    }
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func postingAlert() {
    
    self.view.endEditing(true)
    
    let alert = UIAlertController(title: "🙈 Posting...", message: nil, preferredStyle: .Alert)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func postedAlert() {
    
    dismissViewControllerAnimated(false) { _ in
      
      let alert = UIAlertController(title: "Posted! 🎉", message: nil, preferredStyle: .Alert)
      
      self.presentViewController(alert, animated: true, completion: nil)
      
      NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(CreatePostTest.dismissAlert), userInfo: nil, repeats: false)
    }
  }
  
  func dismissAlert() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}
