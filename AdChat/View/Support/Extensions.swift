//
//  Extensions.swift
//  Contacts
//
//  Created by ark dan on 12/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import UIKit
import UIKitExtensions

extension UIImage {
    func scaled(w: CGFloatConvertible, h: CGFloatConvertible) -> UIImage {
        return scaled(to: CGSize(width: w.cgFloat, height: h.cgFloat))
    }

    func scaled(to size: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIView {
    func makeRound(_ radius: CGFloatConvertible? = nil) {
        let r = radius?.cgFloat ?? bounds.size.height / 2
        layer.cornerRadius = r
        clipsToBounds = true
    }
    func rounded() -> Self {
        makeRound()
        return self
    }
}

extension UICollectionView {
    func scrollToBottom(animated: Bool = true) {
        let lastsection = numberOfSections - 1
        guard lastsection >= 0 else { return }

        let lastItem = numberOfItems(inSection: lastsection) - 1
        guard lastItem >= 0 else { return }

        let indexPath = IndexPath(row: lastItem, section: lastsection)
        scrollToItem(at: indexPath, at: .bottom, animated: animated)
    }
}

extension CGSize {
    func scaleFactorAspectFit(in target: CGSize) -> CGFloat {
        // try to match width
        let scale = target.width / self.width;
        // if we scale the height to make the widths equal, does it still fit?
        if height * scale <= target.height {
            return scale
        }
        // no, match height instead
        return target.height / height
    }

    func scaledAspectFit(in target: CGSize) -> CGSize {
        let scale = scaleFactorAspectFit(in: target)
        let w = width * scale
        let h = height * scale
        return CGSize(width: w, height: h)
    }
}
