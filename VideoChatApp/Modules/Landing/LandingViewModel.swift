//
//  LandingViewModel.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation
import AgoraRtcKit
import AVFoundation

protocol LandingViewModelProtocol {
    var pageTitle: String { get }
    var titleText: String { get }
    var placeholderText: String { get }
    var buttonTitle: String { get }
    var storyboardName: String { get }
    func requestCameraAndMicrophonePermission(completion: @escaping (Bool) -> Void)
}

final class LandingViewModel: LandingViewModelProtocol {
    let pageTitle: String
    let titleText: String
    let placeholderText: String
    let buttonTitle: String
    let storyboardName: String
    
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
            case .granted: completion(true)
            case .denied, .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    completion(granted)
                }
            @unknown default:
                completion(false)
            }
        case .denied, .restricted: completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    switch microphoneAuthorizationStatus {
                    case .granted:
                        completion(true)
                    case .denied, .undetermined:
                        AVAudioSession.sharedInstance().requestRecordPermission { granted in
                            completion(granted)
                        }
                    @unknown default:
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        @unknown default:
            completion(false)
        }
    }
}
