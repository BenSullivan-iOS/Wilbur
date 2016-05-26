//
//  CreatePostVC.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 19/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Spring
import AVFoundation
import FDWaveformView

class CreatePostVC: UIViewController {
  
  @IBOutlet weak var recordButton: SpringButton!
  @IBOutlet weak var playButton: SpringButton!
  @IBOutlet weak var pauseButton: SpringButton!
  
  @IBOutlet weak var controlsBackground: MaterialView!
  
  @IBOutlet weak var timerViewCover: UIView!
  
  @IBOutlet weak var waveFormView: FDWaveformView!
  
  var pressed = false
  var recordingSuccess = Bool()

  var recordingSession: AVAudioSession!
  var audioRecorder: AVAudioRecorder!
  var player = AVAudioPlayer()
  
  @IBAction func playButtonPressed(sender: SpringButton!) {
    
    print("Play button pressed")
    
    play()
  }
  
  func getDocumentsDirectoryForWaveform() -> NSURL {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    
    let url = NSURL(string: documentsDirectory)!
    
    return url
  }
  
  func showWaveForm(fileURL: NSURL) {
    
    print("ShowWaveform")
    
//    let fileURL = getDocumentsDirectoryForWaveform().URLByAppendingPathComponent("recording.mp2")
    
    print(fileURL)
//    let fileURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("audio_test", ofType: "m4a")!)
    
//    let fileURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ding", ofType: "m4a")!)

    self.waveFormView.audioURL = fileURL
//    self.waveFormView.doesAllowScrubbing = false
    self.waveFormView.alpha = 1.0

//    self.waveFormView.doesAllowStretchAndScroll = false
  }
  
  func waveformViewDidRender(waveformView: FDWaveformView) {
    self.waveFormView.alpha = 1.0
  }
  
  @IBAction func recordButtonPressed(sender: UIButton) {
    
    recordTapped()
    
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
        
        self.recordButton.animateToNext {
          
          self.recordButton.duration = 1
          self.recordButton.animation = "pop"
          
          self.recordButton.animateToNext {
            
            self.recordButton.duration = 1
            self.recordButton.animation = "pop"
            
            self.recordButton.animateToNext {
              //            self.recordButton.duration = 1
              //            self.recordButton.animation = "pop"
              
              //            self.recordButton.animateToNext {
              //              self.recordButton.duration = 1
              //              self.recordButton.animation = "pop"
              //              self.recordButton.animateToNext {
              //
              //              }
              //            }
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
    
    //    if recordButton.imageView?.image == UIImage(named: "stopButtonWhite") {
    //
    //      recordButton.imageView?.image = UIImage(named: "recordButtonWhite")
    //
    //    } else {
    //
    //    recordButton.imageView?.image = UIImage(named: "stopButtonWhite")
    //
    //    }
    
  }
  
  override func viewDidLoad() {
    
//    showWaveForm()
    
    record()
    
    playButton.alpha = 0
    pauseButton.alpha = 0
    
    playButton.imageView?.contentMode = .ScaleAspectFit
    pauseButton.imageView?.contentMode = .ScaleAspectFit
    recordButton.imageView?.contentMode = .ScaleAspectFit
    
//    timerMic.imageView?.contentMode = .ScaleAspectFit
    
//    recordTimerBackground.imageView?.contentMode = .ScaleAspectFit
    
  }
  
}
