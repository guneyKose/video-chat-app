//
//  VideoCallViewModel.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation
import AgoraRtcKit

protocol VideoCallViewModelProtocol {
    var isCameraEnabled: Bool { get }
    var isMicOn: Bool { get }
    var userRole: AgoraClientRole { get }
    var joined: Bool { get set }
    var agoraEngine: AgoraRtcEngineKit { get set }
    var remoteVideoIsOn: Bool { get set }
    var remoteAudioIsOn: Bool { get set }
    
    func toggleCamera()
    func switchCamera()
    func toggleMic()
}

final class VideoCallViewModel: VideoCallViewModelProtocol {
    var isCameraEnabled: Bool = true
    var isMicOn: Bool = true
    var userRole: AgoraClientRole = .broadcaster
    var joined: Bool = false
    var agoraEngine: AgoraRtcEngineKit
    var remoteVideoIsOn: Bool = true
    var remoteAudioIsOn: Bool = true
    
    init(agoraEngine: AgoraRtcEngineKit) {
        self.agoraEngine = agoraEngine
    }
    
    func toggleCamera() {
        isCameraEnabled.toggle()
        agoraEngine.muteLocalVideoStream(!isCameraEnabled)
    }
    
    func switchCamera() {
        agoraEngine.switchCamera()
    }
    
    func toggleMic() {
        isMicOn.toggle()
        agoraEngine.muteLocalAudioStream(!isMicOn)
    }
}
