//
//  LandingViewModel.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation
import AVFoundation

protocol LandingViewModel {
    var view: LandingView? { get set }
    var pageTitle: String { get }
    var titleText: String { get }
    var placeholderText: String { get }
    var buttonTitle: String { get }
    var deviceAuthManager: DeviceAuthManager { get set }
    var networkManager: NetworkControl { get set }
    
    func requestCameraAndMicrophonePermission(completion: @escaping (Bool) -> Void)
    func checkUserInput(input: String?, range: NSRange, string: String) -> Bool
    func onStartCall(input: String?)
    func usernameChanged(input: String)
}

final class LandingViewModelImpl: LandingViewModel {
    
    weak var view: LandingView?
    var networkManager: NetworkControl
    var deviceAuthManager: DeviceAuthManager
    let pageTitle: String
    let titleText: String
    let placeholderText: String
    let buttonTitle: String
    
    init(deviceAuthManager: DeviceAuthManager,
         reachabilityManager: ReachabilityManager) {
        pageTitle = "Start a video chat"
        titleText = "Enter your username"
        placeholderText = "Username"
        buttonTitle = "Start Call"
        self.deviceAuthManager = deviceAuthManager
        self.networkManager = reachabilityManager
    }
    
    func requestCameraAndMicrophonePermission(completion: @escaping (Bool) -> Void) {
        let cameraAuthorizationStatus = deviceAuthManager.authStatus(for: .video)
        let microphoneAuthorizationStatus = deviceAuthManager.recordPermission()
        
        switch cameraAuthorizationStatus {
        case .authorized:
            switch microphoneAuthorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    completion(true)
                }
            case .denied, .notDetermined, .restricted:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    completion(granted)
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                completion(false)
            }
        case .notDetermined:
            deviceAuthManager.requestAccess(for: .video) { granted in
                if granted {
                    switch microphoneAuthorizationStatus {
                    case .authorized:
                        DispatchQueue.main.async {
                            completion(true)
                        }
                    case .denied, .notDetermined, .restricted:
                        AVAudioSession.sharedInstance().requestRecordPermission { granted in
                            DispatchQueue.main.async {
                                completion(granted)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        }
    }
    
    func checkUserInput(input: String?, range: NSRange, string: String) -> Bool {
        guard let userInput = input else { return false }
        
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
    
    func onStartCall(input: String?) {
        guard let input = input else { return }
        if input.count > 2 {
            requestCameraAndMicrophonePermission { granted in
                if granted {
                    if self.networkManager.isConnectedToNetwork() {
                        self.view?.navigateToVideoCall()
                    } else {
                        self.view?.showAlert(type: .noInternetConnection)
                    }
                } else {
                    self.view?.showAlert(type: .needPermission)
                }
            }
        } else if input.count == 0 {
            self.view?.showAlert(type: .enterUsername)
        } else {
            self.view?.showAlert(type: .tooShort)
        }
    }
    
    func usernameChanged(input: String) {
        if input.count > 2 {
            view?.changeTextFieldBorderColor(validation: .valid)
        } else {
            view?.changeTextFieldBorderColor(validation: .invalid)
        }
    }
}
