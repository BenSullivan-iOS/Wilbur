//
//  CreatePostVC.swift
//  Fart Club
//
//  Created by Ben Sullivan on 19/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Spring
import AVFoundation
import FDWaveformView
import FirebaseStorage

class CreatePostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var recordButton: SpringButton!
  @IBOutlet weak var playButton: SpringButton!
  @IBOutlet weak var pauseButton: SpringButton!
  
  @IBOutlet weak var descriptionTextField: MaterialTextField!
  @IBOutlet weak var controlsBackground: MaterialView!
  @IBOutlet weak var timerViewCover: UIView!
  @IBOutlet weak var waveFormView: FDWaveformView!
  
  @IBOutlet weak var selectedImage: UIImageView!
  
  var selectedImagePath = NSURL?()
  
  private let imagePicker = UIImagePickerController()
  
  var pressed = false
  var recordingSuccess = Bool()
  var recordingSession: AVAudioSession!
  var audioRecorder: AVAudioRecorder!
  var player = AVAudioPlayer()
  
  //MARK: - VC Lifecycle
  
  override func viewDidLoad() {
    
    setupRecording()
    
    imagePicker.delegate = self
    
    playButton.alpha = 0
    pauseButton.alpha = 0
    
    controlsBackground.backgroundColor = UIColor(colorLiteralRed: 105/255, green: 184/255, blue: 252/255, alpha: 1.0)
    
    playButton.imageView?.contentMode = .ScaleAspectFit
    pauseButton.imageView?.contentMode = .ScaleAspectFit
    recordButton.imageView?.contentMode = .ScaleAspectFit
  }
  
  //MARK: - Audio controls
  
  @IBAction func playButtonPressed(sender: SpringButton!) {
    play(NSURL(fileURLWithPath: String(getDocumentsDirectory()) + "/recording.m4a"))
  }
  
  @IBAction func pauseButtonPressed(sender: AnyObject) {
    pause()
  }
  
  @IBAction func recordButtonPressed(sender: UIButton) {
    
    recordTapped()
    animateRecordControls()
  }
  
  func showWaveForm(fileURL: NSURL) {
    
    self.waveFormView.audioURL = fileURL
    self.waveFormView.doesAllowScrubbing = false
    self.waveFormView.alpha = 1
  }
  
  func waveformViewDidRender(waveformView: FDWaveformView) {
    self.waveFormView.alpha = 1
  }
  
  @IBAction func takePhotoButtonPressed(sender: AnyObject) {
    
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    let i = info[UIImagePickerControllerReferenceURL] as? NSURL
    
    selectedImagePath = i!
    dismissViewControllerAnimated(true, completion: nil)
    
    let image = info[UIImagePickerControllerOriginalImage] as? UIImage
    selectedImage.image = image
    
    let saveDirectory = String(getDocumentsDirectory()) + "/images/tempImage.jpg"
    
    let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    saveImage(tempImage, path: saveDirectory)
    
    print("Did finish picking image - ", saveDirectory)
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
    let jpgImageData = UIImageJPEGRepresentation(compressedImage, 0)
    let result = jpgImageData!.writeToFile(String(path), atomically: true)
    
    selectedImagePath = NSURL(fileURLWithPath: path)
    
    return result
  }
  
  
  
  
  @IBAction func postBarButtonPressed(sender: AnyObject) {
    
    postToFirebase()
  }
  
  func postToFirebase() {
    
    print("Posting to firebase")
    //generates new ID for URL
    let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
    
    let audioPath = NSURL(fileURLWithPath: String(getDocumentsDirectory()) + "/recording.m4a")
    
    CreatePost.shared.uploadAudio(audioPath, firebaseReference: firebasePost.key)
    
    var post: [String: AnyObject] = [
      "description" : descriptionTextField.text!,
      "likes": 0,
      "audio": "audio/\(firebasePost.key).m4a" ]
    
    if let imagePath = selectedImagePath {
      
      uploadImage(imagePath, firebaseReference: firebasePost.key)
      
      post["imageUrl"] = "images/\(firebasePost.key).jpg"
    }
    
    //save to database
    firebasePost.setValue(post)
    
    descriptionTextField.text = ""
    selectedImage.image = UIImage(named: "camera")
    print("Done")
  }

  
  func uploadImage(localFile: NSURL, firebaseReference: String) {
    print("uploadImage", localFile)
    let storageRef = FIRStorage.storage().reference()
    let riversRef = storageRef.child("images/\(firebaseReference).jpg")
    
    riversRef.putFile(localFile, metadata: nil) { metadata, error in
      print("putFile")
      guard let metadata = metadata where error == nil else { print("error", error); return }
      
      let downloadURL = metadata.downloadURL
      
      print("success", downloadURL)
      
      
      //      CreatePost.shared.downloadAudio(localFile)
    }
  }

  
  
  
  

  
  
  
  
  

  
  
  //MARK: - Animations etc...
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    self.view.endEditing(true)
  }
  
  func animateRecordControls() {
    
    if !pressed {
      //      timerViewCover.alpha = 1
      
      //      timerMic.y = 100
      //      timerMic.duration = 10
      //      timerMic.animateTo()
      
      //      recordButton.setImage(UIImage(named: "micIconRecording"), forState: .Normal)
      
      controlsBackground.backgroundColor = UIColor(colorLiteralRed: 252/255, green: 71/255, blue: 103/255, alpha: 1.0)
      
      recordButton.duration = 1
      recordButton.animation = "pop"
      
      recordButton.animateToNext {
        self.recordButton.duration = 1
        self.recordButton.animation = "pop"
        //if button pressed, return from function to stop animation etc...
        self.recordButton.animateToNext {
          self.recordButton.duration = 1
          self.recordButton.animation = "pop"
          
          self.recordButton.animateToNext {
            self.recordButton.duration = 1
            self.recordButton.animation = "pop"
            
            self.recordButton.animateToNext {
              self.recordButton.duration = 1
              self.recordButton.animation = "pop"
              
              self.recordButton.animateToNext {
                self.recordButton.duration = 1
                self.recordButton.animation = "pop"
                
                self.recordButton.animateToNext {
                  self.recordButton.duration = 1
                  self.recordButton.animation = "pop"
                  
                  self.recordButton.animateToNext {
                    self.recordButton.duration = 1
                    self.recordButton.animation = "pop"
                    
                    self.recordButton.animateToNext {
                      self.recordButton.duration = 1
                      self.recordButton.animation = "pop"
                      
                      self.recordButton.animateToNext {
                        self.recordButton.duration = 1
                        self.recordButton.animation = "pop"
                        
                        self.recordButton.animateToNext {
                          self.recordButton.duration = 1
                          self.recordButton.animation = "pop"
                          
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      pressed = true
      
    } else {
      
      
      pauseButton.alpha = 1
      
      playButton.damping = 0.8
      playButton.x = -self.view.bounds.width / 3.5
      playButton.animateTo()
      
      pauseButton.alpha = 1
      
      pauseButton.damping = 0.8
      pauseButton.x = self.view.bounds.width / 3.5
      pauseButton.animateTo()
      
      controlsBackground.backgroundColor = UIColor(colorLiteralRed: 105/255, green: 184/255, blue: 252/255, alpha: 1.0)
      
      pressed = false
    }
    
  }
}
