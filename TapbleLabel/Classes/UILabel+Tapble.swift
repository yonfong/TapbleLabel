//
//  UILabel+Tapble.swift
//  TapbleLabel
//
//  Created by sky on 2022/1/19.
//

import UIKit

public extension NSAttributedString.Key {
    static let tapAction = NSAttributedString.Key("tapAction")
}

public typealias TextTapAction = (() -> Void)

public extension UILabel {
    private struct AssociatedKeys {
        static var enableTextTapAction = "enableTextTapAction"
        static var tapActionGesture = "tapActionGesture"
    }
    
    private var tapActionGesture: UITapGestureRecognizer? {
      get {
        objc_getAssociatedObject(self, &AssociatedKeys.tapActionGesture) as? UITapGestureRecognizer
      }
      set {
        objc_setAssociatedObject(self, &AssociatedKeys.tapActionGesture, newValue, .OBJC_ASSOCIATION_RETAIN)
      }
    }
    
    var isEnableTextTapAction: Bool {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.enableTextTapAction) as? Bool ?? false }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.enableTextTapAction, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if newValue {
                guard let tapGesture = tapActionGesture else {
                    let tap = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
                    addGestureRecognizer(tap)
                    tapActionGesture = tap
                    isUserInteractionEnabled = true
                    return
                }
 
                if tapGesture.view != self {
                    tapGesture.view?.removeGestureRecognizer(tapGesture)
                    addGestureRecognizer(tapGesture)
                }
                isUserInteractionEnabled = true
                tapGesture.isEnabled = true
            } else {
                tapActionGesture?.isEnabled = false
            }
        }
    }

    @objc
    private func labelTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if let tapAction = checkForTapAction(gestureRecognizer) {
            tapAction()
        }
    }

  // thanks to https://stackoverflow.com/a/35789589/405770
    private func checkForTapAction(_ gestureRecognizer: UITapGestureRecognizer) -> TextTapAction? {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attributedText!)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        let labelSize = bounds.size
        textContainer.size = labelSize

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = gestureRecognizer.location(in: self)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        let textContainerOffset = CGPoint(
          x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )

        let locationOfTouchInTextContainer = CGPoint(
          x: locationOfTouchInLabel.x - textContainerOffset.x,
          y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        guard textBoundingBox.contains(locationOfTouchInTextContainer) else {
            return nil
        }

        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return attributedText?.attribute(.tapAction, at: indexOfCharacter, effectiveRange: nil) as? TextTapAction
    }
}

