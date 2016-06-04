//
//  SplashVC.swift
//  FartClub
//
//  Created by Ben Sullivan on 26/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

private struct Quote {
  
  let saidBy: String!
  let quote: String!
}

class SplashVC: UIViewController {
  
  private var viewAppearedFromFeed = Bool()
  
  @IBOutlet weak var quote: UILabel!
  @IBOutlet weak var saidBy: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    let quotes = [
    Quote(saidBy: "Confucious",         quote: "He who smelt it, dealt it"),
    Quote(saidBy: "Queen Elisabeth II", quote: "There is nothing funnier than a fart"),
    Quote(saidBy: "Mr Spock",           quote: "Only a Klingon would fart in an airlock"),
    Quote(saidBy: "Mother Teresa",      quote: "You are only ever one fart away from an early shower"),
    Quote(saidBy: "Evel Knievel",       quote: "To fart in one's sleep, now that's dangerous"),
    Quote(saidBy: "Emily Bronte",       quote: "Love is not having to hold your farts in anymore"),
    Quote(saidBy: "Socrates",           quote: "A fart not smelled is a fart wasted"),
    Quote(saidBy: "Nelson Mandela",     quote: "Children are like farts, people only like their own"),
    Quote(saidBy: "George Washington",  quote: "Flatulence isn't funny, it's hilarious")
    ]
    
    let randomNumber = Int(arc4random_uniform(UInt32(quotes.count)))
    
    quote.text = quotes[randomNumber].quote
    saidBy.text = quotes[randomNumber].saidBy

    NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(SplashVC.checkForUserLoggedIn), userInfo: nil, repeats: false)
  }
  
  override func viewDidAppear(animated: Bool) {
    
    if viewAppearedFromFeed {
      performSegueWithIdentifier(Constants.sharedSegues.signUp, sender: self)
    }
  }
  
  func checkForUserLoggedIn() {
    
    if NSUserDefaults.standardUserDefaults().valueForKey(Constants.shared.KEY_UID) != nil {
      self.performSegueWithIdentifier(Constants.sharedSegues.loggedInFromSplash, sender: self)
    } else {
      self.performSegueWithIdentifier(Constants.sharedSegues.signUp, sender: self)
    }
    
    viewAppearedFromFeed = true
  }
}
