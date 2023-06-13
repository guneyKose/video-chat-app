//
//  LandingViewModel.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation
import AVFoundation

protocol LandingViewModelProtocol {
    var pageTitle: String { get }
    var titleText: String { get }
    var placeholderText: String { get }
    var buttonTitle: String { get }
    var storyboardName: String { get }
    var delegate: LandingProtocol? { get set }
    
    func requestCameraAndMicrophonePermission(completion: @escaping (Bool) -> Void)
    func checkUserInput(input: String?, range: NSRange, string: String) -> Bool
    func onStartCall(input: String?)
}

final class LandingViewModel: LandingViewModelProtocol {
    let pageTitle: String
    let titleText: String
    let placeholderText: String
    let buttonTitle: String
    let storyboardName: String
    weak var delegate: LandingProtocol?
    
    init() {
        pageTitle = "Start a video chat"
        titleText = "Enter your username"
        placeholderText = "Username"
        buttonTitle = "Start Call"
        storyboardName = "VideoCall"
    }
    
    func requestCameraAndMicrophonePermission(completion: @escaping (Bool) -> Void) {
        let cameraAuthorizationStatus =
        AVCaptureDevice.authorizationStatus(for: .video)
        let microphoneAuthorizationStatus =
        AVAudioSession.sharedInstance().recordPermission
        
        switch cameraAuthorizationStatus {
        case .authorized:
            switch microphoneAuthorizationStatus {
            case .granted:
                DispatchQueue.main.async {
                    completion(true)
                }
            case .denied, .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    completion(granted)
                }
            @unknown default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                completion(false)
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    switch microphoneAuthorizationStatus {
                    case .granted:
                        DispatchQueue.main.async {
                            completion(true)
                        }
                    case .denied, .undetermined:
                        AVAudioSession.sharedInstance().requestRecordPermission { granted in
                            DispatchQueue.main.async {
                                completion(granted)
                            }
                        }
                    @unknown default:
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        @unknown default:
            DispatchQueue.main.async {
                completion(false)
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
                    if ReachabilityManager.isConnectedToNetwork() {
                        self.delegate?.navigateToVideoCall()
                    } else {
                        self.delegate?.showAlert(type: .noInternetConnection)
                    }
                } else {
                    self.delegate?.showAlert(type: .needPermission)
                }
            }
        } else if input.count == 0 {
            self.delegate?.showAlert(type: .enterUsername)
        } else {
            self.delegate?.showAlert(type: .tooShort)
        }
    }
}
