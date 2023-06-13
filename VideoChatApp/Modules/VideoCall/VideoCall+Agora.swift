//
//  VideoCall+Agora.swift
//  VideoChatApp
//
//  Created by Güney Köse on 8.06.2023.
//

import Foundation
import AgoraRtcKit

extension VideoCallViewController: AgoraRtcEngineDelegate {
    
    // Callback called when a new host joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = remoteView
        viewModel.agoraEngine?.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteReason, elapsed: Int) {
        switch state {
        case .starting, .decoding:
            viewModel.remoteVideoIsOn = true
            remoteVideoStatusChanged()
        case .stopped, .frozen, .failed:
            viewModel.remoteVideoIsOn = false
            remoteVideoStatusChanged()
        @unknown default: break
        }
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState, reason: AgoraAudioRemoteReason, elapsed: Int) {
        switch state {
        case .starting, .decoding:
            viewModel.remoteAudioIsOn = true
            remoteAudioStatusChanged()
        case .stopped, .frozen, .failed:
            viewModel.remoteAudioIsOn = false
            remoteAudioStatusChanged()
        @unknown default: break
        }
    }
    
    //When remote user leaves the channel.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        endCall()
    }
}
