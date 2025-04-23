//
//  TipCell.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 23/4/2025.
//

import UIKit

class TipCell: UITableViewCell {
  @IBOutlet weak var quoteLabel:  UILabel!
  @IBOutlet weak var authorLabel: UILabel!

  @MainActor
  func configure(with tip: Tip) {
    
    quoteLabel.numberOfLines  = 0
    quoteLabel.lineBreakMode  = .byWordWrapping
    quoteLabel.text           = "“\(tip.quote)”"

    authorLabel.font          = UIFont.italicSystemFont(ofSize: 14)
    authorLabel.textColor     = .darkGray
    authorLabel.text          = tip.author

      contentView.layer.cornerRadius = 8
  }
}

