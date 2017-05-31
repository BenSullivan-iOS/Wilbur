//
//  CreatePostTest.swift
//  Wilbur
//
//  Created by Ben Sullivan on 21/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage

enum AlertState {
  case notLoggedIn
  case noPhoto
}

class CreatePostVC: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, PostButtonPressedDelegate, CreatePostDelegate, HelperFunctions {
  
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var cameraIcon: UIButton!
  @IBOutlet weak var micIcon: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var selectedImage: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  
  fileprivate var checkAudioRecorded = Bool()
  fileprivate let imagePicker = UIImagePickerController()
  fileprivate var selectedImagePath: URL?
  fileprivate let tap = UITapGestureRecognizer()
  
  //MARK: - VC LIFESCYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setDelegates()
    configureTextField()
    configureTapGestureRecogniser()

    scrollView.isScrollEnabled = false
    
    micIcon.imageView?.contentMode = .scaleAspectFit
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    AppState.shared.currentState = .creatingPost
    tap.isEnabled = true
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    tap.isEnabled = false
  }
  
  
  
  //MARK: - BUTTONS

  func postButtonPressed() {
    print("Well done! Creating post etc...")
    postToFirebase()
  }
  
  @IBAction func takePhotoButtonPressed(_ sender: AnyObject) {
    
    guard UserDefaults.standard.value(forKey: "username") != nil else { displayAlert("Function unavailable", message: "You must be logged in to post", state: .notLoggedIn); return }
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      
        imagePickerAlert()
      
    } else {
      present(imagePicker, animated: true, completion: nil)
    }
  }
  
  //MARK: - CREATE POST DELEGATE
  
  func postSuccessful() {
    
    self.postedAlert()
    self.selectedImagePath = nil
    self.descriptionText.text = DescriptionText.defaultText
    
    NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTables"), object: self)
    
    selectedImage.image = UIImage(named: "createPostPlaceholder")
    
    tableView.reloadData()
    
  }
  
  func postError() {
    
    self.dismiss(animated: false) { _ in
      
      self.displayAlert("Error saving image", message: "Please check your internet connection", state: .noPhoto)
    }
  }
  
  //MARK: - POST FUNCTION
  
  func postToFirebase() {
    
    guard AppState.shared.currentState == .creatingPost else {
      
      displayAlert("Error 🤔", message: "Please select 'Create Post'", state: .noPhoto)
      
      return
    }
    
    guard selectedImage.image != UIImage(named: "createPostPlaceholder") else {
      
      displayAlert("🤔 Missing information", message: "Please add a photo", state: .noPhoto)
      
      return
    }
    
    guard let imagePath = selectedImagePath else {
      
      displayAlert("🤔 Missing information", message: "Please add a photo", state: .noPhoto)
      
      return
    }
    
    guard let username = UserDefaults.standard.value(forKey: "username") as? String else { print("no username"); return }
    
    guard let userKey = DataService.ds.currentUserKey else { print("no username key"); return }
    
    var description = descriptionText.text!
    
    if description == DescriptionText.defaultText {
      
      description = ""
    }
    
    postingAlert()
    
    let formatter = DateFormatter()
    let dateString = formatter.string(from: Date())
    
    let post: [String: AnyObject] = [
      "description" : description as AnyObject,
      "user": username as AnyObject,
      "date": dateString as AnyObject,
      "userKey": userKey as AnyObject,
    ]
  
    var postService = PostService()
    postService.delegate = self
    postService.uploadImage(imagePath, username: username, dict: post)
  }
  
  
  //MARK: - TABLE VIEW
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell") as! ImageTable
  
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
    static let defaultText = "Enter description, include your location and as much detail as possible"
  }
  
  func configureTextField() {
    
    descriptionText.layer.cornerRadius = 3.0
    descriptionText.layer.borderWidth = 1.0
    descriptionText.layer.borderColor = UIColor(colorLiteralRed: 170/255, green: 170/255, blue: 170/255, alpha: 0.5).cgColor
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    
    if descriptionText.text == DescriptionText.defaultText {
    descriptionText.text = ""
    }
    descriptionText.textColor = .gray
  }
  
  func tapReceived() {
    
    self.view.endEditing(true)
  }
  
  func configureTapGestureRecogniser() {
    
    tap.addTarget(self, action: #selector(self.tapReceived))
    tap.numberOfTapsRequired = 1
    tap.isEnabled = true

    self.view.addGestureRecognizer(tap)
    
  }
  
  
  //MARK: - CAMERA FUNCTIONS
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

    scrollView.isScrollEnabled = true
    
    dismiss(animated: true, completion: nil)
    
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    selectedImage.image = image
    
    let saveDirectory = docsDirect() + "images/tempImage.jpg"
    
    saveImage(image, path: saveDirectory)
    
    print("Did finish picking image - ", saveDirectory)
    let height = AVMakeRect(aspectRatio: image.size, insideRect: selectedImage.frame).height

    tableView.rowHeight = height
    tableView.reloadData()
  }
  
  func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  
  func saveImage (_ image: UIImage, path: String) -> Bool {
    
    let path2 = docsDirect() + "tempImage.jpg"
    print(path2)
//    let compressedImage = resizeImage(image, newWidth: 1536)
    let compressedImage = resizeImage(image, newWidth: 1000)

    let jpgImageData = UIImageJPEGRepresentation(compressedImage, 0.2)
    let result = (try? jpgImageData!.write(to: URL(fileURLWithPath: path2), options: [.atomic])) != nil
    print(result)
    selectedImagePath = URL(fileURLWithPath: path2)
    
    return result
  }
  
  
  
  
  //MARK: - ALERTS
  
  func imagePickerAlert() {
    
    let alert = UIAlertController(title: "Choose source type", message: "", preferredStyle: .actionSheet)
    alert.popoverPresentationController?.sourceView = self.view
    
    alert.addAction(UIAlertAction(title: "Take photo 📷", style: .default, handler: { action in
      
      self.imagePicker.sourceType = .camera

      //FIXME: - allow cropping
      
      self.present(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    
    alert.addAction(UIAlertAction(title: "Photo library 📱", style: .default, handler: { action in
      
      self.imagePicker.sourceType = .photoLibrary
      self.present(self.imagePicker, animated: true, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(alert, animated: true, completion: nil)
  }
  
  func displayAlert(_ title: String, message: String, state: AlertState) {

    self.view.endEditing(true)
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    switch state {
    case .noPhoto:
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      
    case .notLoggedIn:
      alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { action in
      
        self.dismiss(animated: false, completion: nil)
      
      }))
      
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

      
    }
    
    present(alert, animated: true, completion: nil)
  }
  
  func postingAlert() {
    
    self.view.endEditing(true)
    
    let alert = UIAlertController(title: "🙈 Posting...", message: nil, preferredStyle: .alert)
    
    present(alert, animated: true, completion: nil)
  }
  
  func postedAlert() {
    
    dismiss(animated: false) { _ in
      
      let alert = UIAlertController(title: "Posted! 🎉", message: nil, preferredStyle: .alert)
      
      self.present(alert, animated: true, completion: nil)
      
      Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(CreatePostVC.dismissAlert), userInfo: nil, repeats: false)
    }
  }
  
  func dismissAlert() {
    dismiss(animated: true, completion: nil)
  }
  
  //MARK: - OTHER
  
  func setDelegates() {
    
    tableView.delegate = self
    scrollView.delegate = self
    imagePicker.delegate = self
    descriptionText.delegate = self
  }
  
  //MARK: - DEPRECIATED
  
  //Save audio if available
  
//  @IBAction func recordButtonPressed(sender: UIButton) {
//    
//    AudioControls.shared.recordTapped()
//    
//  }
//  
//  func audioRecorded() {
//    //
//  }
  
  //      if let audioPath = NSURL(fileURLWithPath: String(direct()) + "/recording.m4a").path {
  //
  //        let fileManager = NSFileManager.defaultManager()
  //
  //        if fileManager.fileExistsAtPath(audioPath) {
  //          print("Audio available")
  //
  //          let audioURL = NSURL(fileURLWithPath: String(direct()) + "/recording.m4a")
  //
  //          CreatePost.shared.uploadAudio(audioURL, firebaseReference: firebasePost.key)
  //
  //          post["audio"] = "audio/\(firebasePost.key).m4a"
  //
  //        } else {
  //          print("Audio unavailable")
  //        }
  //      }
}
