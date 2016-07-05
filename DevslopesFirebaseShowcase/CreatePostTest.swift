//
//  CreatePostTest.swift
//  Wildlife
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
    AppState.shared.currentState = .CreatingPost
    tap.enabled = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    tap.enabled = false
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("imageCell") as! ImageTable
  
    if selectedImage.image != nil {
    cell.tableImage.image = selectedImage.image
    }
    
    return cell
    
  }
 
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  @IBAction func takePhotoButtonPressed(sender: AnyObject) {
    
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      imagePickerAlert()
    } else {
      presentViewController(imagePicker, animated: true, completion: nil)
    }
  }
  
  struct DescriptionText {
    static let defaultText = "Enter description, include as much detail as possible"
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    
    if descriptionText.text == DescriptionText.defaultText {
    descriptionText.text = ""
    }
    descriptionText.textColor = .grayColor()
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    
    
  }
  
  func tapReceived() {
    
    print("tapped")
    
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
    
    let saveDirectory = String(HelperFunctions.getDocumentsDirectory()) + "/images/tempImage.jpg"
    
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
    let compressedImage = resizeImage(image, newWidth: 1536)
    let jpgImageData = UIImageJPEGRepresentation(compressedImage, 0)
    let result = jpgImageData!.writeToFile(path2, atomically: true)
    print(result)
    selectedImagePath = NSURL(fileURLWithPath: path2)
    
    return result
  }
  
  
  
  
    func postToFirebase() {
  
      let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
      
      guard let username = NSUserDefaults.standardUserDefaults().valueForKey("username") else { print("no username"); return }
  
      guard let userKey = NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) as? String else { print("no username key"); return }
  
      var post: [String: AnyObject] = [
  "description" : descriptionText.text!,
         "likes": 0,
          "user": username,
          "date": String(NSDate()),
       "userKey": userKey
      ]
    
      
      //Save audio if available
      
      if let audioPath = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/recording.m4a").path {
        
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(audioPath) {
          print("Audio available")
          
          let audioURL = NSURL(fileURLWithPath: String(HelperFunctions.getDocumentsDirectory()) + "/recording.m4a")
          
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
   
        self.checkAudioRecorded = false
      }
  
      firebasePost.setValue(post)
  
      descriptionText.text = ""
      selectedImage.image = UIImage(named: "camera")
  
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
        
        NSNotificationCenter.defaultCenter().postNotificationName("imageSaved", object: self)
        
//        addObserver(self, selector: #selector(FeedVC.reloadTable(_:)), name: "imageSaved", object: nil)

        
      }
    }

  
  func imagePickerAlert() {
    
    let alert = UIAlertController(title: "Choose source type", message: "", preferredStyle: .ActionSheet)
    alert.popoverPresentationController?.sourceView = self.view
    
    alert.addAction(UIAlertAction(title: "Take photo", style: .Default, handler: { action in
      
      self.imagePicker.sourceType = .Camera
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    
    alert.addAction(UIAlertAction(title: "Photo library", style: .Default, handler: { action in
      
      self.imagePicker.sourceType = .PhotoLibrary
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  
}
