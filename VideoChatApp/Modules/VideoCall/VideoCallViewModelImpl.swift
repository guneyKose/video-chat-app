//
//  VideoCallViewModel.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation
import AgoraRtcKit
import AgoraRtmKit

protocol VideoCallViewModel: AgoraRtcEngineDelegate, AgoraRtmDelegate {
    var view: VideoCallView? { get set }
    var videoCallManager: VideoCallManager { get set }
    var chatManager: ChatManager { get set }
    var username: String? { get set }
    var isMessageInputOpen: Bool { get set }
    var messages: [Message] { get set }
    
    func onViewDidLoad()
    func endCall()
    func messageTapped()
    func sendMessage(_ msg: String)
}
//AgoraRtcEngineDelegate
final class VideoCallViewModelImpl: NSObject, VideoCallViewModel {
    weak var view: VideoCallView?
    var videoCallManager: VideoCallManager
    var chatManager: ChatManager
    var username: String?
    var isMessageInputOpen: Bool = false
    var messages: [Message] = []
    
    init(agoraManager: VideoCallManager,
         chatManager: ChatManager) {
        self.videoCallManager = agoraManager
        self.chatManager = chatManager
    }
    
    func onViewDidLoad() {
        videoCallManager.setupLocalVideo()
        videoCallManager.initializeAgoraEngine(delegate: self)
        videoCallManager.joinChannel()
        chatManager.login(username: username!, delegate: self)
    }
    
    func endCall() {
        videoCallManager.leaveChannel()
    }
    
    func messageTapped() {
        isMessageInputOpen.toggle()
        view?.toggleKeyboard(isMessageInputOpen)
    }
    
    func sendMessage(_ msg: String) {
        let msg = Message(username: username ?? "N/A", message: msg)
        chatManager.send(message: msg)
        messages.append(msg)
        view?.reloadChat(sender: true)
    }
    
    // Callback called when a new host joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        videoCallManager.didJoinedOfUid(uid: uid)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteReason, elapsed: Int) {
        videoCallManager.remoteVideoStatusChanged(state)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState, reason: AgoraAudioRemoteReason, elapsed: Int) {
        videoCallManager.remoteAudioStatusChanged(state)
    }
    
    //When remote user leaves the channel.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        view?.endCall()
    }
    
    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        debugPrint("\(peerId) \(message.text)")
    }
}
