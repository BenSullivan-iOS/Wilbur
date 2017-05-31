//
//  AppState.swift
//  Wilbur
//
//  Created by Ben Sullivan on 04/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

class AppState {
  
  static let shared = AppState()
  
  fileprivate init() {}
  
  fileprivate var _currentState = State.none
  
  var currentState: State {
    
    get {
      return _currentState
    }
    
    set {
      _currentState = newValue
    }
  }
  
  enum State {
    case creatingPost
    case feed
    case answered
    case presentLoginFromComments
    case none
  }
}
