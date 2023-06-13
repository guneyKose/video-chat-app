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
    var agoraEngine: AgoraRtcEngineKit? { get set }
    var remoteVideoIsOn: Bool { get set }
    var remoteAudioIsOn: Bool { get set }
    
    func toggleCamera()
    func switchCamera()
    func toggleMic()
    func initializeAgoraEngine(delegate: AgoraRtcEngineDelegate)
    func setupLocalVideo(localView: UIView)
    func joinChannel(localView: UIView)
    func leaveChannel()
}

final class VideoCallViewModel: VideoCallViewModelProtocol {
    var isCameraEnabled: Bool = true
    var isMicOn: Bool = true
    var userRole: AgoraClientRole = .broadcaster
    var joined: Bool = false
    var agoraEngine: AgoraRtcEngineKit?
    var remoteVideoIsOn: Bool = true
    var remoteAudioIsOn: Bool = true
    
    init() {
        
    }
    
    func toggleCamera() {
        isCameraEnabled.toggle()
        agoraEngine?.muteLocalVideoStream(!isCameraEnabled)
    }
    
    func switchCamera() {
        agoraEngine?.switchCamera()
    }
    
    func toggleMic() {
        isMicOn.toggle()
        agoraEngine?.muteLocalAudioStream(!isMicOn)
    }
    
    func initializeAgoraEngine(delegate: AgoraRtcEngineDelegate) {
        let config = AgoraRtcEngineConfig()
        // Pass in your App ID here.
        config.appId = agoraAppID
        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: delegate)
    }
    
    func setupLocalVideo(localView: UIView) {
        // Enable the video module
        agoraEngine?.enableVideo()
        // Start the local video preview
        agoraEngine?.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        // Set the local video view
        agoraEngine?.setupLocalVideo(videoCanvas)
    }
    
    func joinChannel(localView: UIView) {
        let option = AgoraRtcChannelMediaOptions()

        // Set the client role option as broadcaster or audience.
        if userRole == .broadcaster {
            option.clientRoleType = .broadcaster
            setupLocalVideo(localView: localView)
        } else {
            option.clientRoleType = .audience
        }

        // For a video call scenario, set the channel profile as communication.
        option.channelProfile = .communication

        // Join the channel with a temp token. Pass in your token and channel name here
        let result = agoraEngine?.joinChannel(
            byToken: nil, channelId: "test", uid: 0, mediaOptions: option,
            joinSuccess: { (channel, uid, elapsed) in }
        )
            // Check if joining the channel was successful and set joined Bool accordingly
        if result == 0 {
            joined = true
        }
    }

    func leaveChannel() {
        agoraEngine?.stopPreview()
        let result = agoraEngine?.leaveChannel(nil)
        // Check if leaving the channel was successful and set joined Bool accordingly
        if result == 0 { joined = false }
    }
}
