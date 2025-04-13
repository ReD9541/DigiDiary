//
//  CustomUIVIew.swift
//  DigiDiary
//
//  Created by Ritesh Dhungel on 11/4/2025.
//

import UIKit

class CustomUIView: UIView {
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
