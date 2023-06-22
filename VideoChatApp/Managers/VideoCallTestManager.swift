//
//  VideoCallTestManager.swift
//  VideoChatApp
//
//  Created by Güney Köse on 20.06.2023.
//

import Foundation
import AgoraRtcKit
import AVFoundation

class VideoCallTestManagerImpl: NSObject, VideoCallManager {
    
    weak var view: VideoCallView?
    var videoEngine: AgoraRtcEngineKit?
    var isCameraEnabled: Bool = true
    var isMicOn: Bool = true
    var joined: Bool = false
    var userRole: AgoraClientRole = .broadcaster
    var remoteView: UIView = UIView()
    var localView: UIView = UIView()
    var blurView: UIVisualEffectView
    var micImage: UIImageView
    var player: AVPlayer?

    override init() {
        let blurEffect = UIBlurEffect(style: .regular)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        self.micImage = UIImageView()
        self.micImage.tintColor = .white
        self.micImage.image = UIImage(systemName: "mic.slash.fill")
    }
    

    func initializeVideoEngine() {
        let config = AgoraRtcEngineConfig()
        // Pass in your App ID here.
        config.appId = agoraAppID
        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        videoEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        self.testRemoteStatusChanges()
    }

    func toggleCamera() {
        debugPrint("toggleCamera")
        localView.isHidden.toggle()
    }

    func switchCamera() {
        debugPrint("switchCamera")
    }

    func toggleMic() {
        player?.isMuted.toggle()
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
        debugPrint("setupLocalVideo")
        playVideo(isLocal: true)
    }

    func joinChannel() {
        debugPrint("joinChannel")
        playVideo(isLocal: false)
        rtcEngine(videoEngine!, didJoinedOfUid: 10, elapsed: 0)
    }

    func leaveChannel() {
        debugPrint("leaveChannel")
        player?.pause()
        player = nil
    }

    func didJoinedOfUid(uid: UInt) {
        debugPrint("didJoinedOfUid")
    }

    private func playVideo(isLocal: Bool) {
        DispatchQueue.main.async {
            let view = isLocal ? self.localView : self.remoteView
            let videoName = isLocal ? "localVideo" : "remoteVideo"
            guard let path = Bundle.main.path(forResource: videoName, ofType:"mp4")
            else { return }

            self.player = AVPlayer(url: URL(fileURLWithPath: path))
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = view.bounds
            playerLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(playerLayer)
            self.player?.isMuted = true

            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: self.player?.currentItem,
                                                   queue: nil) { _ in
                self.player?.seek(to: CMTime.zero)
                self.player?.play()
            }

            self.player?.play()
        }
    }
    
    // Callback called when a new host joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        didJoinedOfUid(uid: uid)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteReason, elapsed: Int) {
        remoteVideoStatusChanged(state)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState, reason: AgoraAudioRemoteReason, elapsed: Int) {
        remoteAudioStatusChanged(state)
    }
    
    //When remote user leaves the channel.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        view?.endCall()
    }
    
    func testRemoteStatusChanges() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.rtcEngine(self.videoEngine!, remoteVideoStateChangedOfUid: 10, state: .failed, reason: .remoteOffline, elapsed: 0)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: {
            self.rtcEngine(self.videoEngine!, remoteAudioStateChangedOfUid: 10, state: .frozen, reason: .localMuted, elapsed: 0)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 9, execute: {
            self.rtcEngine(self.videoEngine!, remoteVideoStateChangedOfUid: 10, state: .decoding, reason: .audioFallback, elapsed: 0)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 11, execute: {
            self.rtcEngine(self.videoEngine!, remoteAudioStateChangedOfUid: 10, state: .starting, reason: .localMuted, elapsed: 0)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 13, execute: {
            self.rtcEngine(self.videoEngine!, remoteVideoStateChangedOfUid: 10, state: .frozen, reason: .internal, elapsed: 0)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
            self.rtcEngine(self.videoEngine!, remoteVideoStateChangedOfUid: 10, state: .starting, reason: .codecNotSupport, elapsed: 0)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 17, execute: {
            self.rtcEngine(self.videoEngine!, didOfflineOfUid: 10, reason: .quit)
        })
    }
}
