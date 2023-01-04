//
//  UITextView+Placeholder.swift
//  UITextViewPlaceholder
//
//  Created by dyljqq dev on 2023/1/4.
//

import UIKit

private var placeholderKey: UInt8 = 0
private var placeholderViewKey: UInt8 = 0

extension UITextView {
    public var placeholder: String? {
        get {
            return objc_getAssociatedObject(self, &placeholderKey) as? String
        }
        
        set {
            guard newValue != placeholder else { return }
            objc_setAssociatedObject(self, &placeholderKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            updatePlaceholderTextView()
        }
    }
    
    var placeholderTextView: UITextView {
        get {
            if let textView = objc_getAssociatedObject(self, &placeholderViewKey) as? UITextView {
                return textView
            }
            return createPlaceholderTextView()
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updatePlaceholderTextView()
    }
}

private extension UITextView {
    func createPlaceholderTextView() -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = Self.defaultPlaceholderColor()
        textView.isUserInteractionEnabled = false
        textView.isAccessibilityElement = false
        
        objc_setAssociatedObject(self, &placeholderViewKey, textView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        updatePlaceholderTextView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaceholderTextView), name: UITextView.textDidChangeNotification, object: nil)
        setupObservers()
                
        return textView
    }
    
    @objc func updatePlaceholderTextView() {
        if self.text.isEmpty {
            self.insertSubview(placeholderTextView, at: 0)
            placeholderTextView.text = placeholder
        } else {
            placeholderTextView.removeFromSuperview()
        }
        
        if placeholderTextView.attributedText.length == 0 {
            placeholderTextView.textAlignment = textAlignment
        }
        
        placeholderTextView.font = font
        placeholderTextView.textContainer.exclusionPaths = textContainer.exclusionPaths
        placeholderTextView.textContainerInset = textContainerInset
        placeholderTextView.textContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        placeholderTextView.frame = bounds
    }
    
    class func defaultPlaceholderColor() -> UIColor {
        if #available(iOS 13.0, *) {
            let selector = NSSelectorFromString("placeholderTextColor")
            if UIColor.responds(to: selector),
               let v = UIColor.perform(selector),
               let color = v.takeUnretainedValue() as? UIColor {
                return color
            }
        }
        return UITextField().defaultPlaceholderColor
    }
    
    func setupObservers() {
        for key in Self.observingKeys {
            self.addObserver(self, forKeyPath: key, options: .new, context: nil)
        }
    }
    
    class var observingKeys: [String] {
        return [
            "attributedText",
            "text",
            "frame",
            "bounds",
            "textAlignment",
            "font",
            "textContainerInset",
            "textContainer.lineFragmentPadding",
            "textContainer.exclusionPaths"
        ]
    }
}

private extension UITextField {
    var defaultPlaceholderColor: UIColor {
        placeholder = " "
        guard let attributes = self.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil),
              let color = attributes[NSAttributedString.Key.foregroundColor] as? UIColor else {
            return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        }
        return color
    }
}
