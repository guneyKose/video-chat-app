//
//  LandingViewController.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import UIKit
import SnapKit

import UIKit
import SnapKit

class LandingViewController: UIViewController {
    
    var viewModel: LandingViewModelProtocol?
    
    var mainTitleLabel: UILabel!
    var usernameTextField: UITextField!
    var startCallButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = LandingViewModel()
    }
    
    init(viewModel: LandingViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - SetUp UI
    private func setupUI() {
        self.navigationItem.title = viewModel?.pageTitle
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        usernameTextField = UITextField()
        mainTitleLabel = UILabel()
        startCallButton = UIButton()
        
        self.view.addSubview(usernameTextField)
        self.view.addSubview(mainTitleLabel)
        self.view.addSubview(startCallButton)
        
        mainTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width - 40)
            make.top.equalTo(view.snp.top).offset(200)
            make.centerX.equalTo(view)
        }
        
        usernameTextField.snp.makeConstraints { make in
            make.width.equalTo(mainTitleLabel)
            make.top.equalTo(mainTitleLabel.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
        }
        
        startCallButton.snp.makeConstraints { make in
            make.width.equalTo(mainTitleLabel)
            make.top.equalTo(usernameTextField.snp.bottom).offset(20)
            make.height.equalTo(50)
            make.centerX.equalTo(view)
        }
        
        mainTitleLabel.text = viewModel?.titleText
        
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.placeholder = viewModel?.placeholderText
        usernameTextField.becomeFirstResponder()
        usernameTextField.delegate = self
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.cornerStyle = .capsule
        
        startCallButton.setTitleColor(.white, for: .normal)
        startCallButton.setTitle(viewModel?.buttonTitle, for: .normal)
        startCallButton.configuration = buttonConfig
        startCallButton.addTarget(self, action: #selector(startCall), for: .touchUpInside)
    }
    
    @objc func startCall() {
        if usernameTextField.text?.count ?? 0 > 2 {
            // Start video call
        } else if !usernameTextField.hasText {
            self.present(AlertManager.enterUsername.alert, animated: true)
        } else {
            self.present(AlertManager.tooShort.alert, animated: true)
        }
    }
}

//MARK: - TextFieldDelegate
extension LandingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let userInput = textField.text else { return false }
        
        let newText = (userInput as NSString).replacingCharacters(in: range, with: string)
        
        let max = 12
        
        if (string == "\n" && userInput.contains("\n")) {
            return false
        } else {
            return newText.count <= max
        }
    }
}
