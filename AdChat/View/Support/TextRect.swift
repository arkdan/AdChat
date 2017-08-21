//
//  TextRect.swift
//  AdChat
//
//  Created by mac on 8/20/17.
//  Copyright © 2017 ark dan. All rights reserved.
//

import UIKit

struct TextRect {
    var font: UIFont
    var maxWidth: CGFloat

    var fontSize: CGFloat {
        get {
            return font.pointSize
        }
        set {
            font = font.withSize(newValue)
        }
    }

    func size(of text: String) -> CGSize {

        var estimated = NSString(string: text)
            .boundingRect(with: CGSize(width: maxWidth, height: 100500),
                          options: [.usesFontLeading, .usesLineFragmentOrigin],
                          attributes: [NSFontAttributeName: font],
                          context: nil)
            .size
        estimated.width += 23
        estimated.height += 8
        return estimated
    }

    static var messages: TextRect = {
        return TextRect(font: UIFont.systemFont(ofSize: 18), maxWidth: UIScreen.main.bounds.size.width)
    }()
}

extension MessageCellViewModel {

    var contentSize: CGSize {
        switch messageInfo.content {

        case .text(let text):
            return TextRect.messages.size(of: text)
        case .image(let data):
            let image = UIImage(data: data)!

            let scaled = image.size.scaledAspectFit(in: CGSize(width: 120, height: 120))
            return scaled
        }
    }
}
