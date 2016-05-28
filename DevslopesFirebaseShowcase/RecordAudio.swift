//
//  RecordAudio.swift
//  Fart Club
//
//  Created by Ben Sullivan on 23/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//
import AVFoundation

extension CreatePostVC: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
  
  func setupRecording() {
    
    recordingSession = AVAudioSession.sharedInstance()
    
    do {
      
      try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DefaultToSpeaker)
      try recordingSession.setActive(true)
      recordingSession.requestRecordPermission() { (allowed: Bool) -> Void in
        dispatch_async(dispatch_get_main_queue()) {
          if allowed {
            print("recording allowed")
          } else {
            print("recording not allowed")
          }
        }
      }
    } catch let error as NSError {
      
      print("failed to setup", error.debugDescription)
    }
    
  }
  
  func recordTapped() {
    
    if audioRecorder == nil {
      startRecording()
    } else {
      finishRecording(success: true)
    }
  }
  
  func startRecording() {
    
    print("preparing to record")
    
    let audioURL = NSURL(fileURLWithPath: String(getDocumentsDirectory()) + "recording.m4a")

    let settings = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: 12000.0,
      AVNumberOfChannelsKey: 1 as NSNumber,
      AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
    ]
    
    do {
      audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
      print("Recording...")
      audioRecorder.delegate = self
      audioRecorder.record()
      recordingSuccess = true
      NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(CreatePostVC.finishRecording(success: )), userInfo: nil, repeats: false)
      
    } catch {
      finishRecording(success: false)
    }
  }
    
  func finishRecording(success success: Bool) {
    
    print("Finished recording")
    if recordingSuccess {
      if audioRecorder != nil {
        
        print("stopping recording")
        audioRecorder.stop()
        audioRecorder = nil

    
    if success || recordingSuccess {
      
      print("Recording successful")
      recordingSuccess = false

      CreatePost.shared.saveAudio(NSURL(fileURLWithPath: String(getDocumentsDirectory()) + "recording.m4a"))
    } else {
      // recording failed :(
    }
        
      }
    }
  }
  
  func play(fileURL: NSURL) {
    
    do {
      
      player = try AVAudioPlayer(contentsOfURL: fileURL)
      player.prepareToPlay()
      player.delegate = self
      player.play()
      
      showWaveForm(fileURL)
      
    } catch {
      print("error playing file", error)
    }
  }
  
  func pause() {
    
    player.pause()
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
  
}