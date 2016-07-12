//
//  AppState.swift
// Wilbur
//
//  Created by Ben Sullivan on 04/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

class AppState {
  
  static let shared = AppState()
  
  var currentState = State.None {
    
    didSet {
      print("CURRENT STATE DID SET,", currentState)
    }
  }
  
  enum State {
    case CreatingPost
    case Feed
    case Answered
    case PresentLoginFromComments
    case None
  }
}