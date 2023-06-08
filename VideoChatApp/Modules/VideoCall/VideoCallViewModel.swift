//
//  VideoCallViewModel.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation
import AgoraRtcKit

final class VideoCallViewModel {
    
    var agoraEngine: AgoraRtcEngineKit!
    var userRole: AgoraClientRole = .broadcaster
    var joined = false
    var isCameraEnabled = true
    var isMicOn = true    
}
