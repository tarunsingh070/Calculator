//
//  RoundLabel.swift
//  Calculator
//
//  Created by Tarun Singh on 2017-09-20.
//  Copyright © 2017 Tarun Singh. All rights reserved.
//

import UIKit

@IBDesignable
class RoundLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat = 0.0
    @IBInspectable var leftInset: CGFloat = 20.0
    @IBInspectable var rightInset: CGFloat = 20.0
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            // Setting masksToBounds to true in order to make the modifications to cornerRadius visible.
            self.layer.masksToBounds = true
            // Update the corner radius of round label when changed from the attributes inspector.
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    /*
     Draw text with the default insets or custom insets provided from the attributes inspector of a 
     RoundLabel.
     */
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    /*
     Update the size of the UILabel to match the edge insets.
     */
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}
