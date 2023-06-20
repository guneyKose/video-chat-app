//
//  VideoCallManager.swift
//  VideoChatApp
//
//  Created by Güney Köse on 14.06.2023.
//

import Foundation
import AgoraRtcKit

protocol VideoCallManager {
    var view: VideoCallView? { get set }
    var agoraEngine: AgoraRtcEngineKit? { get set }
    var isCameraEnabled: Bool { get }
    var isMicOn: Bool { get }
    var userRole: AgoraClientRole { get }
    var joined: Bool { get set }
    var remoteView: UIView { get set }
    var localView: UIView { get set }
    var blurView: UIVisualEffectView { get set }
    var micImage: UIImageView { get set }
    
    func toggleCamera()
    func switchCamera()
    func toggleMic()
    func initializeAgoraEngine(delegate: AgoraRtcEngineDelegate)
    func setupLocalVideo()
    func joinChannel()
    func leaveChannel()
    func remoteVideoStatusChanged(_ state: AgoraVideoRemoteState)
    func remoteAudioStatusChanged(_ state: AgoraAudioRemoteState)
    func didJoinedOfUid(uid: UInt)
}

class VideoCallManagerImpl: VideoCallManager {
    weak var view: VideoCallView?
    var agoraEngine: AgoraRtcEngineKit?
    var isCameraEnabled: Bool = true
    var isMicOn: Bool = true
    var joined: Bool = false
    var userRole: AgoraClientRole = .broadcaster
    var remoteView: UIView = UIView()
    var localView: UIView = UIView()
    var blurView: UIVisualEffectView
    var micImage: UIImageView
    
    init() {
        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        micImage = UIImageView()
        micImage.tintColor = .white
        micImage.image = UIImage(systemName: "mic.slash.fill")
        micImage.isHidden = true
    }
    
    func initializeAgoraEngine(delegate: AgoraRtcEngineDelegate) {
        let config = AgoraRtcEngineConfig()
        // Pass in your App ID here.
        config.appId = agoraAppID
        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: delegate)
    }
    
    func toggleCamera() {
        isCameraEnabled.toggle()
        agoraEngine?.muteLocalVideoStream(!isCameraEnabled)
        let videoIcon: ButtonIconType = isCameraEnabled ? .videoOn : .videoOff
        view?.changeButtonIcons(mic: nil, video: videoIcon)
        localView.isHidden = !isCameraEnabled
    }
    
    func switchCamera() {
        agoraEngine?.switchCamera()
    }
    
    func toggleMic() {
        isMicOn.toggle()
        agoraEngine?.muteLocalAudioStream(!isMicOn)
        let micIcon: ButtonIconType = isMicOn ? .micOn : .micOff
        view?.changeButtonIcons(mic: micIcon, video: nil)
    }
    
    func remoteVideoStatusChanged(_ state: AgoraVideoRemoteState) {
        switch state {
        case .starting, .decoding:
            blurView.removeFromSuperview()
        case .failed, .frozen, .stopped:
            blurView.frame = remoteView.frame
            if remoteView.contains(micImage) {
                remoteView.insertSubview(blurView, belowSubview: micImage)
            } else {
                remoteView.addSubview(blurView)
            }
        @unknown default: break
        }
    }
    
    func remoteAudioStatusChanged(_ state: AgoraAudioRemoteState) {
        switch state {
        case .starting, .decoding:
            micImage.removeFromSuperview()
        case .failed, .frozen, .stopped:
            remoteView.addSubview(micImage)
            micImage.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 50, height: 50))
                make.center.equalTo(remoteView.center)
            }
        @unknown default: break
        }
    }
    
    func setupLocalVideo() {
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
    
    func joinChannel() {
        let option = AgoraRtcChannelMediaOptions()

        // Set the client role option as broadcaster or audience.
        if userRole == .broadcaster {
            option.clientRoleType = .broadcaster
            setupLocalVideo()
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
    
    func didJoinedOfUid(uid: UInt) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = remoteView
        agoraEngine?.setupRemoteVideo(videoCanvas)
    }
}
