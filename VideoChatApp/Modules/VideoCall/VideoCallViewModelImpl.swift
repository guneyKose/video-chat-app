//
//  VideoCallViewModel.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation

protocol VideoCallViewModel {
    var view: VideoCallView? { get set }
    var videoCallManager: VideoCallManager { get set }
    var chatManager: ChatManager { get set }
    var username: String? { get set }
    var isMessageInputOpen: Bool { get set }
    var messages: [Message] { get set }
    var isChatVisible: Bool { get set }
    
    func onViewDidLoad()
    func endCall()
    func messageTapped()
    func sendMessage(_ msg: String)
    func messageReceived(_ msg: Message)
}

final class VideoCallViewModelImpl: NSObject, VideoCallViewModel {
    weak var view: VideoCallView?
    var videoCallManager: VideoCallManager
    var chatManager: ChatManager
    var username: String?
    var isMessageInputOpen: Bool = false
    var messages: [Message] = []
    var timer: Timer?
    var isChatVisible: Bool = false {
        didSet {
            if isChatVisible && !isMessageInputOpen {
                timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
                    if !self.isMessageInputOpen {
                        self.view?.hideChat(true)
                    }
                    timer.invalidate()
                    self.timer = nil
                }
            }
        }
    }
    
    init(videoManager: VideoCallManager,
         chatManager: ChatManager) {
        self.videoCallManager = videoManager
        self.chatManager = chatManager
    }
    
    func onViewDidLoad() {
        videoCallManager.setupLocalVideo()
        videoCallManager.initializeVideoEngine()
        videoCallManager.joinChannel()
        chatManager.login(username: username!) {
            self.chatManager.createChannel()
        }
    }
    
    func endCall() {
        videoCallManager.leaveChannel()
        chatManager.logout()
    }
    
    func messageTapped() {
        view?.toggleKeyboard(true)
    }
    
    func sendMessage(_ msg: String) {
        let msg = Message(username: username!, message: msg)
        chatManager.send(message: msg) { [weak self] sent in
            guard sent else { return }
            guard let self else { return }
            self.messages.append(msg)
            self.view?.reloadChat()
        }
    }
    
    func messageReceived(_ msg: Message) {
        messages.append(msg)
        timer?.invalidate()
        timer = nil
        view?.reloadChat()
        view?.hideChat(false)
    }
}
