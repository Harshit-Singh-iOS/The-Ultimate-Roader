//
//  UITextView+Placeholder.swift
//  Ultimate Roader
//

import UIKit
import ObjectiveC

private final class PlaceholderLabel: UILabel {}

private struct PlaceholderAssociatedKeys {
    static var labelKey: UInt8 = 0
    static var textKey: UInt8 = 0
    static var colorKey: UInt8 = 0
}

extension UITextView {
    var placeholder: String? {
        get { objc_getAssociatedObject(self, &PlaceholderAssociatedKeys.textKey) as? String }
        set {
            objc_setAssociatedObject(self, &PlaceholderAssociatedKeys.textKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            placeholderLabel.text = newValue
            updatePlaceholderVisibility()
        }
    }

    var placeholderColor: UIColor? {
        get { objc_getAssociatedObject(self, &PlaceholderAssociatedKeys.colorKey) as? UIColor }
        set {
            objc_setAssociatedObject(self, &PlaceholderAssociatedKeys.colorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            placeholderLabel.textColor = newValue ?? .lightGray
        }
    }

    private var placeholderLabel: UILabel {
        if let label = objc_getAssociatedObject(self, &PlaceholderAssociatedKeys.labelKey) as? UILabel {
            return label
        }

        let label = PlaceholderLabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChangeNotification(_:)),
            name: UITextView.textDidChangeNotification,
            object: self
        )

        objc_setAssociatedObject(self, &PlaceholderAssociatedKeys.labelKey, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return label
    }

    @objc private func textDidChangeNotification(_ notification: Notification) {
        updatePlaceholderVisibility()
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(text?.isEmpty ?? true)
    }
}
