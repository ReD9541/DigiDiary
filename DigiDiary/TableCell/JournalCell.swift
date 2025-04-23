//
//  JournalCell.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 23/4/2025.
//

import UIKit

class JournalCell: UITableViewCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var titleLabel:  UILabel!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!


  @MainActor
  func configure(with journal: Journal) {
    

    contentView.layer.cornerRadius = 8
  }
}
