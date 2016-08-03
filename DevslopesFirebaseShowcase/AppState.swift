//
//  AppState.swift
//  Wilbur
//
//  Created by Ben Sullivan on 04/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

class AppState {
  
  static let shared = AppState()
  
  private init() {}
  
  private var _currentState = State.None
  
  var currentState: State {
    
    get {
      return _currentState
    }
    
    set {
      _currentState = newValue
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