//
//  FartFactsTVC.swift
//  FartClub
//
//  Created by Ben Sullivan on 02/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

private extension CollectionType {
  /// Return a copy of `self` with its elements shuffled
  func shuffle() -> [Generator.Element] {
    var list = Array(self)
    list.shuffleInPlace()
    return list
  }
}

private extension MutableCollectionType where Index == Int {
  /// Shuffle the elements of `self` in-place.
  mutating func shuffleInPlace() {
    // empty and single-element collections don't shuffle
    if count < 2 { return }
    
    for i in 0..<count - 1 {
      let j = Int(arc4random_uniform(UInt32(count - i))) + i
      guard i != j else { continue }
      swap(&self[i], &self[j])
    }
  }
}


class FartFactsTVC: UITableViewController {
  
  private var fartFacts = FartFacts().facts
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fartFacts = fartFacts.shuffle()
    
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fartFacts.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("fartFactsCell", forIndexPath: indexPath)
    
    cell.textLabel?.text = fartFacts[indexPath.row]
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.textAlignment = .Center
    cell.textLabel?.adjustsFontSizeToFitWidth = true
    cell.textLabel?.textColor = .grayColor()
    cell.textLabel?.font = UIFont(name: "Baskerville", size: 18)
    
    return cell
  }
  
  var secondRow = NSIndexPath(forRow: 1, inSection: 0)
  var firstRow = NSIndexPath(forRow: 0, inSection: 0)

  override func viewWillAppear(animated: Bool) {
//    tableView.scrollToRowAtIndexPath(secondRow, atScrollPosition: .None, animated: false)
    fartFacts = fartFacts.shuffle()
    tableView.reloadData()
    print("will appear")

  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    return self.view.bounds.height
  }
  
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
   if editingStyle == .Delete {
   // Delete the row from the data source
   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
   } else if editingStyle == .Insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
