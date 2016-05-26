//
//  RecordAudio.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 23/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//
import AVFoundation

extension CreatePostVC: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
  
  func record() {
    
    recordingSession = AVAudioSession.sharedInstance()
    
    do {
      
      try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DefaultToSpeaker)
      try recordingSession.setActive(true)
      recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
        dispatch_async(dispatch_get_main_queue()) {
          if allowed {
            print("recording allowed")
            //load recording ui?
          } else {
            print("recording not allowed")
            // failed to recovar
          }
        }
      }
    } catch let error as NSError {
      
      print("failed to setup", error.debugDescription)
      // failed to record!
    }
    
  }
  
  func startRecording() {
    
    print("preparing to record")
    
    let audioURL = getDocumentsDirectory().URLByAppendingPathComponent("recording.m4a")
    
    let settings = [
      AVFormatIDKey: Int(kAudioFormatAC3),
      AVSampleRateKey: 12000.0,
      AVNumberOfChannelsKey: 1 as NSNumber,
      AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
    ]
    
    let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)),
                          AVFormatIDKey : NSNumber(int: Int32(kAudioFormatAppleLossless)),
                          AVNumberOfChannelsKey : NSNumber(int: 1),
                          AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue)),
                          AVEncoderBitRateKey : NSNumber(int: Int32(320000))]
    
    do {
      audioRecorder = try AVAudioRecorder(URL: audioURL, settings: recordSettings)
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

      play()
    } else {
      // recording failed :(
    }
        
      }
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
    
    let fileURL = getDocumentsDirectory().URLByAppendingPathComponent("recording.m4a")
    
    var stringfileURL = String(fileURL)
    
    let shorter = stringfileURL.stringByReplacingOccurrencesOfString("/Users/Ben/Library/Developer/CoreSimulator/Devices/", withString: " ")
    
    let evenShorter = shorter.stringByReplacingOccurrencesOfString("data/Containers/Data/Application", withString: " ")
    print(evenShorter)
    
    do {
      
      player = try AVAudioPlayer(contentsOfURL: fileURL)
      player.prepareToPlay()
      //      player.volume = 1
      player.delegate = self
      player.play()
      
      showWaveForm(fileURL)
      
      
    } catch {
      print("error playing file")
    }
    
  }
}