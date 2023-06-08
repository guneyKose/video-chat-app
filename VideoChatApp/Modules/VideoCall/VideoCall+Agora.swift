//
//  VideoCall+Agora.swift
//  VideoChatApp
//
//  Created by Güney Köse on 8.06.2023.
//

import Foundation
import AgoraRtcKit

extension VideoCallViewController: AgoraRtcEngineDelegate {
    
    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        // Pass in your App ID here.
        config.appId = agoraAppID
        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        viewModel.agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    }
    
    // Callback called when a new host joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = remoteView
        viewModel.agoraEngine.setupRemoteVideo(videoCanvas)
    }
    
    func setupLocalVideo() {
        // Enable the video module
        viewModel.agoraEngine.enableVideo()
        // Start the local video preview
        viewModel.agoraEngine.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        // Set the local video view
        viewModel.agoraEngine.setupLocalVideo(videoCanvas)
    }
    
    func joinChannel() {
        let option = AgoraRtcChannelMediaOptions()

        // Set the client role option as broadcaster or audience.
        if viewModel.userRole == .broadcaster {
            option.clientRoleType = .broadcaster
            setupLocalVideo()
        } else {
            option.clientRoleType = .audience
        }

        // For a video call scenario, set the channel profile as communication.
        option.channelProfile = .communication

        // Join the channel with a temp token. Pass in your token and channel name here
        let result = viewModel.agoraEngine.joinChannel(
            byToken: nil, channelId: "test", uid: 0, mediaOptions: option,
            joinSuccess: { (channel, uid, elapsed) in }
        )
            // Check if joining the channel was successful and set joined Bool accordingly
        if result == 0 {
            viewModel.joined = true
        }
    }

    func leaveChannel() {
        viewModel.agoraEngine.stopPreview()
        let result = viewModel.agoraEngine.leaveChannel(nil)
        // Check if leaving the channel was successful and set joined Bool accordingly
        if result == 0 { viewModel.joined = false }
    }
}
