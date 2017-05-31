//
//  Protocols.swift
//  Wilbur
//
//  Created by Ben Sullivan on 19/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

protocol NavigationBarDelegate: class {
  func didSelectSegment(_ segment: Int)
}

protocol UpdateNavButtonsDelegate: class {
  func updateNavButtons()
}

protocol PostButtonPressedDelegate: class {
  func postButtonPressed()
}

protocol ReloadTableDelegate: class {
  func reloadTable()
}

protocol PostCellDelegate: class {
  func showAlert(_ post: Post)
  func customCellCommentButtonPressed()
}

protocol MyPostsCellDelegate: class {
  func showComments(_ post: Post, image: UIImage)
  func showDeleteAlert(_ post: Post)
}

protocol CreatePostDelegate {
  func displayAlert(_ title: String, message: String, state: AlertState)
  func postSuccessful()
  func postError()
}
