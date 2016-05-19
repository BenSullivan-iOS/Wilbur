//
//  CreatePostVC.swift
//  DevslopesFirebaseShowcase
//
//  Created by Ben Sullivan on 19/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class CreatePostVC: UIViewController {
  
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var pauseButton: UIButton!
  
  @IBAction func recordButtonPressed(sender: UIButton) {
    
    if recordButton.imageView?.image == UIImage(named: "stopButtonWhite") {
      
      recordButton.imageView?.image = UIImage(named: "recordButtonWhite")
      
    } else {
    
    recordButton.imageView?.image = UIImage(named: "stopButtonWhite")
    
    }
    
  }
  
  
  override func viewDidLoad() {
    
    playButton.imageView?.contentMode = .ScaleAspectFit
    pauseButton.imageView?.contentMode = .ScaleAspectFit
    recordButton.imageView?.contentMode = .ScaleAspectFit

    
  }

}
