//
//  RoundButton.swift
//  Calculator
//
//  Created by Tarun Singh on 2017-09-20.
//  Copyright © 2017 Tarun Singh. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            // Update the corner radius of round button when changed from the attributes inspector.
            self.layer.cornerRadius = cornerRadius
        }
    }

}
