//
//  MessageBar.swift
//  Firebase Roader Demo
//

import UIKit

enum MessageType {
    case error
    case success
    case info
}

struct MessageBarConfig {
    let errorColor: UIColor
    let successColor: UIColor
    let infoColor: UIColor

    final class Builder {
        private var errorColor: UIColor = .systemRed
        private var successColor: UIColor = .systemGreen
        private var infoColor: UIColor = .systemBlue

        func withErrorColor(_ color: UIColor) -> Builder {
            errorColor = color
            return self
        }

        func withSuccessColor(_ color: UIColor) -> Builder {
            successColor = color
            return self
        }

        func withInfoColor(_ color: UIColor) -> Builder {
            infoColor = color
            return self
        }

        func build() -> MessageBarConfig {
            MessageBarConfig(errorColor: errorColor, successColor: successColor, infoColor: infoColor)
        }
    }
}

final class SwiftMessageBar {
    private static var sharedConfig = MessageBarConfig.Builder().build()
    private static let barTag = 987654

    static func setSharedConfig(_ config: MessageBarConfig) {
        sharedConfig = config
    }

    static func showMessageWithTitle(_ title: String, message: String, type: MessageType) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return
            }

            let barView = UIView()
            barView.tag = barTag
            barView.backgroundColor = color(for: type)
            barView.layer.cornerRadius = 10
            barView.layer.masksToBounds = true

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .boldSystemFont(ofSize: 14)
            titleLabel.textColor = .white

            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = .systemFont(ofSize: 13)
            messageLabel.textColor = .white
            messageLabel.numberOfLines = 0

            let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
            stack.axis = .vertical
            stack.spacing = 2
            stack.translatesAutoresizingMaskIntoConstraints = false

            barView.addSubview(stack)
            barView.translatesAutoresizingMaskIntoConstraints = false

            window.viewWithTag(barTag)?.removeFromSuperview()
            window.addSubview(barView)

            NSLayoutConstraint.activate([
                barView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
                barView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16),
//                barView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 12),
                barView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -68),

                stack.leadingAnchor.constraint(equalTo: barView.leadingAnchor, constant: 12),
                stack.trailingAnchor.constraint(equalTo: barView.trailingAnchor, constant: -12),
                stack.topAnchor.constraint(equalTo: barView.topAnchor, constant: 10),
                stack.bottomAnchor.constraint(equalTo: barView.bottomAnchor, constant: -10)
            ])

            barView.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                barView.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.25, delay: 2.0, options: [], animations: {
                    barView.alpha = 0
                }) { _ in
                    barView.removeFromSuperview()
                }
            }
        }
    }

    private static func color(for type: MessageType) -> UIColor {
        switch type {
        case .error:
            return sharedConfig.errorColor
        case .success:
            return sharedConfig.successColor
        case .info:
            return sharedConfig.infoColor
        }
    }
}
