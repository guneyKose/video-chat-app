//
//  LandingViewController.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import UIKit
import SnapKit

enum UsernameValidation {
    case valid, invalid
    var color: UIColor {
        switch self {
        case .valid:
            return .green
        case .invalid:
            return .red
        }
    }
}

protocol LandingView: AnyObject {
    func showAlert(type: AlertManager)
    func navigateToVideoCall()
    func changeTextFieldBorderColor(validation: UsernameValidation)
}

class LandingViewController: UIViewController {
    var viewModel: LandingViewModel!
    var mainTitleLabel: UILabel!
    var usernameTextField: UITextField!
    var startCallButton: UIButton!
    var keyboardHeight: CGFloat?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(viewModel: LandingViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.viewModel.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - SetUp UI
    private func setupUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        self.navigationItem.title = viewModel.pageTitle
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        usernameTextField = UITextField()
        mainTitleLabel = UILabel()
        startCallButton = UIButton()
        
        self.view.addSubview(usernameTextField)
        self.view.addSubview(mainTitleLabel)
        self.view.addSubview(startCallButton)
        
        mainTitleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-40)
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
        
        mainTitleLabel.text = viewModel.titleText
        
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.placeholder = viewModel.placeholderText
        usernameTextField.becomeFirstResponder()
        usernameTextField.delegate = self
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none
        usernameTextField.layer.borderWidth = 1
        usernameTextField.layer.cornerRadius = 6
        usernameTextField.layer.borderColor = UIColor.red.cgColor
        
        let buttonConfig = UIButton.Configuration.filled()
        
        startCallButton.setTitleColor(.systemBackground, for: .normal)
        startCallButton.tintColor = .label
        startCallButton.setTitle(viewModel.buttonTitle, for: .normal)
        startCallButton.configuration = buttonConfig
        startCallButton.addTarget(self, action: #selector(startCall), for: .touchUpInside)
    }
    
    @objc func startCall() {
        self.viewModel.onStartCall(input: usernameTextField.text)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }
}

//MARK: - LandingProtocol
extension LandingViewController: LandingView {
    func showAlert(type: AlertManager) {
        let alert = type.alert
        self.present(alert, animated: true)
    }
    
    func navigateToVideoCall() {
        let videoManager = VideoCallTestManagerImpl()
        let chatManager = ChatManagerTestImpl()
        let viewModel = VideoCallViewModelImpl(videoManager: videoManager,
                                               chatManager: chatManager)
        let vc = VideoCallViewController(viewModel: viewModel)
        vc.viewModel.username = usernameTextField.text
        vc.keyboardHeight = self.keyboardHeight
        UIView.transition(with: self.navigationController!.view,
                          duration: 0.3,
                          options: .transitionFlipFromRight,
                          animations: {
            self.navigationController?.pushViewController(vc, animated: false)
        }, completion: nil)
    }
    
    func changeTextFieldBorderColor(validation: UsernameValidation) {
        usernameTextField.layer.borderColor = validation.color.cgColor
    }
}

//MARK: - TextFieldDelegate
extension LandingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.usernameChanged(input: textField.text ?? "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        viewModel.checkUserInput(input: textField.text, range: range, string: string)
    }
}
