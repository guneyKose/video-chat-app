//
//  DeviceAuthManager.swift
//  VideoChatApp
//
//  Created by Güney Köse on 14.06.2023.
//

import AVFoundation

enum DeviceType {
    case video, audio
}

enum AuthStatus {
    case notDetermined
    case restricted
    case denied
    case authorized
}

protocol DeviceAuth {
    func recordPermission() -> AuthStatus
    func authStatus(for media: DeviceType) -> AuthStatus
    func requestAccess(for media: DeviceType, _ completion: @escaping (Bool) -> Void)
}

class DeviceAuthManager: DeviceAuth {
    
    func recordPermission() -> AuthStatus {
        let auth = AVAudioSession.sharedInstance().recordPermission
        
        switch auth {
        case .undetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .granted:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }
    
    func authStatus(for media: DeviceType) -> AuthStatus {
        let mediaType: AVMediaType
        
        switch media {
        case .video:
            mediaType = .video
        case .audio:
            mediaType = .audio
        }
        
        let auth = AVCaptureDevice.authorizationStatus(for: mediaType)
        
        switch auth {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }
    
    func requestAccess(for media: DeviceType, _ completion: @escaping (Bool) -> Void) {
        let mediaType: AVMediaType
        
        switch media {
        case .video:
            mediaType = .video
        case .audio:
            mediaType = .audio
        }
        
        AVCaptureDevice.requestAccess(for: mediaType) { granted in
            completion(granted)
        }
    }
}
