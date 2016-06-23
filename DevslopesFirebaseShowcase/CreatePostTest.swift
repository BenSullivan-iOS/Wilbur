//
//  CreatePostTest.swift
//  Wildlife
//
//  Created by Ben Sullivan on 21/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioPlayerDelegate {

  func audioRecorded()
}

class ImageTable: UITableViewCell {
  
  @IBOutlet weak var tableImage: UIImageView!
  
}

class CreatePostTest: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, PostButtonPressedDelegate {
  
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var cameraIcon: UIButton!
  @IBOutlet weak var micIcon: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var selectedImage: UIImageView!
  @IBOutlet weak var tableView: UITableView!
    
  private let imagePicker = UIImagePickerController()
  private var selectedImagePath = NSURL?()
  
  let tap = UITapGestureRecognizer()
  
  func postButtonPressed() {
    print("Well done! Creating post etc...")
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
    
    let image = info[UIImagePickerControllerOriginalImage] as? UIImage
    selectedImage.image = image
    
    let saveDirectory = String(HelperFunctions.getDocumentsDirectory()) + "/images/tempImage.jpg"
    
    let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    saveImage(tempImage, path: saveDirectory)
    
    print("Did finish picking image - ", saveDirectory)
    let height = AVMakeRectWithAspectRatioInsideRect((image?.size)!, selectedImage.frame).height

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
  
  func saveImage (image: UIImage, path: String) -> Bool {
    
    let compressedImage = resizeImage(image, newWidth: 1536)
    if let jpgImageData = UIImageJPEGRepresentation(compressedImage, 0) {
    let result = jpgImageData.writeToFile(String(path), atomically: true)
      selectedImagePath = NSURL(fileURLWithPath: path)

      return result
    }
    return false
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
