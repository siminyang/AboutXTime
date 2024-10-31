//
//  CustomTextEditor.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/10/1.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - 膠囊文字訊息匡
struct CustomTextEditor: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String
    @Binding var isNotFocused: Bool
    var fontSize: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(context.coordinator.doneButtonTapped)
        )

        let buttonFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        doneButton.setTitleTextAttributes([
            .foregroundColor: UIColor.systemBlue,
            .font: buttonFont
        ], for: .normal)

        doneButton.setTitleTextAttributes([
            .foregroundColor: UIColor.gray,
            .font: buttonFont
        ], for: .highlighted)

        toolbar.setItems([flexibleSpace, doneButton], animated: true)

        textView.inputAccessoryView = toolbar
        textView.delegate = context.coordinator
        textView.text = placeholder
        textView.textColor = .lightGray

        textView.backgroundColor = UIColor(white: 1.0, alpha: 0.4)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            if !self.isNotFocused && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if self.isNotFocused && uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }

        if uiView.text != text && !uiView.isFirstResponder {
            uiView.text = text.isEmpty ? placeholder : text
            uiView.textColor = text.isEmpty ? .lightGray : .white
        }

        uiView.font = UIFont.systemFont(ofSize: fontSize)
        uiView.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        @objc func doneButtonTapped() {
            parent.isNotFocused = true
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isNotFocused = false
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = .white
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isNotFocused = true
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .lightGray
            }
            parent.text = textView.text
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

// MARK: - from to
struct CustomTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(parent: CustomTextField) {
            self.parent = parent
        }

        @objc func doneButtonTapped() {
            parent.textField.resignFirstResponder()
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }

    @Binding var text: String
    let placeholder: String
    private let textField = UITextField()

    func makeUIView(context: Context) -> UIView {
        textField.delegate = context.coordinator
        textField.text = text
        textField.textColor = UIColor.white
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.doneButtonTapped)
        )

        let buttonFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        doneButton.setTitleTextAttributes([
            .foregroundColor: UIColor.systemBlue,
            .font: buttonFont
        ], for: .normal)

        doneButton.setTitleTextAttributes([
            .foregroundColor: UIColor.gray,
            .font: buttonFont
        ], for: .highlighted)

        toolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = toolbar

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
        textField.leftView = paddingView
        textField.rightView = paddingView
        textField.leftViewMode = .always
        textField.rightViewMode = .always

        let containerView = UIView()
        containerView.addSubview(textField)

        textField.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: 300),
            textField.heightAnchor.constraint(equalToConstant: 30),
            containerView.widthAnchor.constraint(equalTo: textField.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: textField.heightAnchor)
        ])

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let textField = uiView.subviews.first as? UITextField {
            textField.text = text
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: UIColor.lightGray,
                    .font: UIFont.systemFont(ofSize: 14)
                ]
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

// MARK: - recipientId
struct CustomIdTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomIdTextField

        init(parent: CustomIdTextField) {
            self.parent = parent
        }

        @objc func doneButtonTapped() {
            parent.textField.resignFirstResponder()
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }

    @Binding var text: String
    let placeholder: String
    private let textField = UITextField()
    var isEditable: Bool

    func makeUIView(context: Context) -> UIView {
        textField.delegate = context.coordinator
        textField.text = text
        textField.textColor = UIColor.white
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.doneButtonTapped)
        )

        let buttonFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        doneButton.setTitleTextAttributes([
            .foregroundColor: UIColor.systemBlue,
            .font: buttonFont
        ], for: .normal)

        doneButton.setTitleTextAttributes([
            .foregroundColor: UIColor.gray,
            .font: buttonFont
        ], for: .highlighted)

        toolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = toolbar

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
        textField.leftView = paddingView
        textField.rightView = paddingView
        textField.leftViewMode = .always
        textField.rightViewMode = .always

        let containerView = UIView()
        containerView.addSubview(textField)

        textField.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: 290),
            textField.heightAnchor.constraint(equalToConstant: 40),
            containerView.widthAnchor.constraint(equalTo: textField.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: textField.heightAnchor)
        ])

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let textField = uiView.subviews.first as? UITextField {
            textField.text = text
            textField.textColor = isEditable ? UIColor.white : UIColor.darkGray
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: UIColor.lightGray,
                    .font: UIFont.systemFont(ofSize: 14)
                ]
            )
            textField.isUserInteractionEnabled = isEditable
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

// MARK: - reply section
struct CustomReplyTextEditor: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomReplyTextEditor
        var placeholderLabel: UILabel?

        init(parent: CustomReplyTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        @objc func doneButtonTapped() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        textView.textColor = UIColor.white
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.doneButtonTapped)
        )

        let buttonFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        doneButton.setTitleTextAttributes([
            .foregroundColor: UIColor.systemBlue,
            .font: buttonFont
        ], for: .normal)

        doneButton.setTitleTextAttributes([
            .foregroundColor: UIColor.gray,
            .font: buttonFont
        ], for: .highlighted)

        toolbar.items = [flexibleSpace, doneButton]
        toolbar.isUserInteractionEnabled = true
        textView.inputAccessoryView = toolbar

        let placeholderLabel = UILabel()
           placeholderLabel.text = placeholder
           placeholderLabel.font = UIFont.systemFont(ofSize: 14)
           placeholderLabel.textColor = UIColor.lightGray
           placeholderLabel.numberOfLines = 0
           placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

           textView.addSubview(placeholderLabel)

           NSLayoutConstraint.activate([
               placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
               placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
               placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -5)
           ])

           placeholderLabel.isHidden = !textView.text.isEmpty

           context.coordinator.placeholderLabel = placeholderLabel

           return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        context.coordinator.placeholderLabel?.isHidden = !text.isEmpty
    }
}
