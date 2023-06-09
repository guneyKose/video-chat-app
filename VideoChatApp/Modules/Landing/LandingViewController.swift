//
//  LandingViewController.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import UIKit
import SnapKit

class LandingViewController: UIViewController {
    
    var viewModel: LandingViewModelProtocol!
    
    var mainTitleLabel: UILabel!
    var usernameTextField: UITextField!
    var startCallButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(viewModel: LandingViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
    }
    
    //MARK: - SetUp UI
    private func setupUI() {
        self.navigationItem.title = viewModel.pageTitle
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
    
    func setupViewModel() {
        self.viewModel = LandingViewModel()
    }
    
    @objc func startCall() {
        if usernameTextField.text?.count ?? 0 > 2 {
            viewModel.requestCameraAndMicrophonePermission { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.goToCall()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showCameraPermissionAlert()
                    }
                }
            }
        } else if !usernameTextField.hasText {
            self.present(AlertManager.enterUsername.alert, animated: true)
        } else {
            self.present(AlertManager.tooShort.alert, animated: true)
        }
    }
    
    func showCameraPermissionAlert() {
        let alertController = UIAlertController(
            title: "Camera and Mic Usage",
            message: "You need to give permission to video chat.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func goToCall() {
        let storyboard = UIStoryboard(name: viewModel.storyboardName, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: VideoCallViewController.id) as? VideoCallViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - TextFieldDelegate
extension LandingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if usernameTextField.text?.count ?? 0 > 2 {
            usernameTextField.layer.borderColor = UIColor.green.cgColor
        } else {
            usernameTextField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let userInput = textField.text else { return false }
        
        let newText = (userInput as NSString).replacingCharacters(in: range, with: string)
        
        //Max char count.
        let max = 12
        
        //Only numbers and letters.
        let permittedCharacters = CharacterSet.letters.union(CharacterSet.decimalDigits)
        let characterSet = CharacterSet(charactersIn: string)
        
        if string == "\n" && userInput.contains("\n") {
            return false
        } else {
            return newText.count <= max && permittedCharacters.isSuperset(of: characterSet)
        }
    }
}
