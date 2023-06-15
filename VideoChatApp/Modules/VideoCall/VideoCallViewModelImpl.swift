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
    
    func onViewDidLoad()
    func onViewDidDisappear()
}

final class VideoCallViewModelImpl: VideoCallViewModel {
    var agoraManager: AgoraManager
    weak var view: VideoCallView?
    
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
}
