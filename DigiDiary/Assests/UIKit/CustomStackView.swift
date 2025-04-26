//
//  CustomStackView.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 14/5/2025.
//

import UIKit

class CustomStackView: UIStackView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 6
    }
}
