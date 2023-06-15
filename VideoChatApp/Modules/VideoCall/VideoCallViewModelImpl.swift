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
    var isMessageInputOpen: Bool { get set }
    
    func onViewDidLoad()
    func onViewDidDisappear()
    func messageTapped()
}

final class VideoCallViewModelImpl: VideoCallViewModel {
    
    weak var view: VideoCallView?
    var agoraManager: AgoraManager
    var username: String?
    var isMessageInputOpen: Bool = false
    
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
}
