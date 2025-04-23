//
//  JournalCell.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 23/4/2025.
//

import UIKit

class JournalCell: UITableViewCell {
    
    // MARK: - IBOutlets
   
    @IBOutlet weak var titleLabel:  UILabel!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    // MARK: - Populating Cell
    //populating the cell with data from a Journal instance.
    @MainActor
    func configure(with journal: Journal) {
       
        contentView.layer.cornerRadius  = 8
        backgroundColor                  = .clear
        selectionStyle                   = .none
        
      
        titleLabel.text    = journal.title
        emotionLabel.text  = journal.emotion.description
        
        //to format the date into short form
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        dateLabel.text = df.string(from: journal.date)
        
        // adding word wrap so it doesn't break the journal content
        contentLabel.text          = journal.content
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
    }
}
