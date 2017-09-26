/*
 * File name : RoundButton.swift
 * Author: Tarun Singh
 * Date: September 20, 2017
 * Student ID: 300967393
 * Description: Custom UIButton class to make the button corners rounded.
 * Version: 0.1
 * Copyright © 2017 Tarun Singh. All rights reserved.
 */

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
