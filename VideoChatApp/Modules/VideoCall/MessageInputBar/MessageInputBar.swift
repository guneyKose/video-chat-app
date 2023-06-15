//
//  MessageInputBar.swift
//  VideoChatApp
//
//  Created by Güney Köse on 15.06.2023.
//

import UIKit

class MessageInputBar: UIView {
    
    var chatTextField: UITextField = {
       let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = .gray
        textField.textColor = .systemBackground
        return textField
    }()
    
    var sendMessageButton: UIButton = {
        let button = UIButton()
        let icon = UIImage(systemName: "paperplane.fill")
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .dynamic
        button.configuration = config
        button.tintColor = .gray
        button.setImage(icon, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        addSubview(chatTextField)
        addSubview(sendMessageButton)
        chatTextField.delegate = self
        createConstraints()
        sendMessageButton.addTarget(self,
                                    action: #selector(sendMessage),
                                    for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func createConstraints() {
        chatTextField.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-60)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }
        
        sendMessageButton.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(chatTextField)
            make.centerY.equalToSuperview()
            make.leading.equalTo(chatTextField.snp.trailing).offset(10)
        }
    }
    
    @objc func sendMessage() {
        debugPrint(chatTextField.text ?? "")
        chatTextField.text = ""
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
        }
    }
}

extension MessageInputBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
    }
}
