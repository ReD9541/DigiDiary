//
//  TipCell.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 23/4/2025.
//

import UIKit

class TipCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var quoteLabel:  UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    
    // MARK: - Populating Cell (
    @MainActor
    func configure(with tip: Tip) {
        //to fix word wrapping so it doesn't break
        quoteLabel.numberOfLines  = 0
        quoteLabel.lineBreakMode  = .byWordWrapping
        quoteLabel.text           = "“\(tip.quote)”"
        
        //to make author label in italics
        authorLabel.font          = UIFont.italicSystemFont(ofSize: 14)
        authorLabel.textColor     = .darkGray
        authorLabel.text          = tip.author
        
        contentView.layer.cornerRadius = 8
        backgroundColor                  = .clear
        selectionStyle                   = .none
    }
}
