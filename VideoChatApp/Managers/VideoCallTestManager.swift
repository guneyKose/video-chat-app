//
//  VideoCallTestManager.swift
//  VideoChatApp
//
//  Created by Güney Köse on 20.06.2023.
//

import Foundation
import AgoraRtcKit
import AVFoundation

class VideoCallTestManagerImpl: VideoCallManager {
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
    var player: AVPlayer?
    
    init() {
        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        micImage = UIImageView()
        micImage.tintColor = .white
        micImage.image = UIImage(systemName: "mic.slash.fill")
    }
    
    func initializeAgoraEngine(delegate: AgoraRtcEngineDelegate) {
        debugPrint("initializeAgoraEngine")
    }
    
    func toggleCamera() {
        debugPrint("toggleCamera")
    }
    
    func switchCamera() {
        debugPrint("switchCamera")
    }
    
    func toggleMic() {
        player?.isMuted.toggle()
    }
    
    func remoteVideoStatusChanged(_ state: AgoraVideoRemoteState) {
        debugPrint("remoteVideoStatusChanged")
    }
    
    func remoteAudioStatusChanged(_ state: AgoraAudioRemoteState) {
        debugPrint("remoteAudioStatusChanged")
    }
    
    func setupLocalVideo() {
        debugPrint("setupLocalVideo")
        let url = "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        playVideo(view: localView, urlStr: url)
    }
    
    func joinChannel() {
        debugPrint("joinChannel")
        let url = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
        playVideo(view: remoteView, urlStr: url)
    }
    
    func leaveChannel() {
        debugPrint("leaveChannel")
        player?.pause()
        player = nil
    }
    
    func didJoinedOfUid(uid: UInt) {
        debugPrint("didJoinedOfUid")
    }
    
    private func playVideo(view: UIView, urlStr: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            let url = URL(string: urlStr)
            self.player = AVPlayer(url: url!)
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = view.bounds
            debugPrint("frame: \(playerLayer.frame)")
            playerLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(playerLayer)
            self.player?.isMuted = true
            self.player?.play()
            debugPrint("playVideo")
        })
    }
}
