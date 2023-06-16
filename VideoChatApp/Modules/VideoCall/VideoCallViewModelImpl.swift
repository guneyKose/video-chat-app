//
//  VideoCallViewModel.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation

protocol VideoCallViewModel {
    var view: VideoCallView? { get set }
    var agoraManager: AgoraManager { get set }
    var username: String? { get set }
    var keyboardHeight: CGFloat? { get set }
    var isMessageInputOpen: Bool { get set }
    var messages: [Message] { get set }
    
    func onViewDidLoad()
    func onViewDidDisappear()
    func messageTapped()
    func sendMessage(_ msg: String)
}

final class VideoCallViewModelImpl: VideoCallViewModel {
    
    weak var view: VideoCallView?
    var agoraManager: AgoraManager
    var username: String?
    var isMessageInputOpen: Bool = false
    var keyboardHeight: CGFloat?
    var messages: [Message] = []
    
    init(agoraManager: AgoraManager) {
        self.agoraManager = agoraManager
    }
    
    func onViewDidLoad() {
        agoraManager.setupLocalVideo()
        agoraManager.initializeAgoraEngine()
        agoraManager.joinChannel()
    }
    
    func onViewDidDisappear() {
        agoraManager.leaveChannel()
    }
    
    func messageTapped() {
        isMessageInputOpen.toggle()
        view?.toggleKeyboard(isMessageInputOpen)
    }
    
    func sendMessage(_ msg: String) {
        let msg = Message(username: username ?? "N/A", message: msg)
        messages.append(msg)
        view?.reloadChat()
        
    }
}
