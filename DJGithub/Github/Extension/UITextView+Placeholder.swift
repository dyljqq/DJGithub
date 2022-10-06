//
//  UITextView+Placeholder.swift
//  DJGithub
//
//  Created by jiqinqiang on 2022/10/6.
//

import UIKit

private var placeholderLabelKey: UInt8 = 0

extension UITextView: UITextViewDelegate {
  
  var placeholderLabel: UILabel? {
    get {
      return objc_getAssociatedObject(self, &placeholderLabelKey) as? UILabel
    }
    set {
      objc_setAssociatedObject(self, &placeholderLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  var placeholder: String? {
    get {
      return self.placeholderLabel?.text
    }
    set {
      if self.placeholderLabel == nil {
        self.addPlaceholder(with: newValue)
      }
      if newValue == nil || newValue!.isEmpty {
        self.placeholderLabel?.isHidden = true
      } else {
        self.placeholderLabel?.isHidden = false
      }
      self.placeholderLabel?.text = newValue
      self.resizePlaceholderLabel()
    }
  }
  
  public func textViewDidChange(_ textView: UITextView) {
    placeholderLabel?.isHidden = !textView.text.isEmpty
  }
  
  private func resizePlaceholderLabel() {
    let x = self.textContainer.lineFragmentPadding
    let y = self.textContainerInset.top
    
    if let placeholder = placeholder {
      let rect = (placeholder as NSString).boundingRect(
        with: CGSize(width: 0, height: 20),
        options: .usesLineFragmentOrigin,
        attributes: [NSAttributedString.Key.font: self.placeholderLabel?.font ?? UIFont.systemFont(ofSize: 14)],
        context: nil)
      placeholderLabel?.frame = CGRect(x: x, y: y, width: rect.width, height: 20)
    }
  }
  
  private func addPlaceholder(with placeholder: String?) {
    let label = UILabel()
    label.textColor = .lightGray
    label.text = placeholder
    label.font = self.font
    label.isHidden = !self.text.isEmpty
    self.addSubview(label)
    self.delegate = self
    self.placeholderLabel = label
    
    self.resizePlaceholderLabel()
  }
  
}
