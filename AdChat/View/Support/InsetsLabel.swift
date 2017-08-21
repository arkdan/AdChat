//
//  InsetsLabel.swift
//  AdChat
//
//  Created by mac on 8/20/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import UIKit

final class InsetsLabel: UILabel {
    var insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) {
        didSet {
            setNeedsDisplay()
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
