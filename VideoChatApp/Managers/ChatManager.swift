//
//  ChatManager.swift
//  VideoChatApp
//
//  Created by Güney Köse on 19.06.2023.
//

import Foundation
import AgoraRtmKit

protocol ChatManager {
    var view: VideoCallView? { get set }
    var kit: AgoraRtmKit? { get set }
    var rtmChannel: AgoraRtmChannel? { get set }
    
    func createChannel(delegate: AgoraRtmChannelDelegate)
    func login(username: String, delegate: AgoraRtmDelegate, _ completion: @escaping () -> Void)
    func logout()
    func send(message: Message, _ completion: @escaping (Bool) -> Void)
    func messageReceived(message: Message)
}

class ChatManagerImpl: ChatManager {
    
    weak var view: VideoCallView?
    var rtmChannel: AgoraRtmChannel?
    var kit: AgoraRtmKit?
    
    init() {
        
    }
    
    func login(username: String, delegate: AgoraRtmDelegate, _ completion: @escaping () -> Void) {
        kit = AgoraRtmKit(appId: agoraAppID, delegate: delegate)
        kit?.agoraRtmDelegate = delegate
        kit?.login(byToken: nil, user: username) { [unowned self] (errorCode) in
            guard errorCode == .ok else {
                debugPrint("Login Error Code: ", errorCode)
                return
            }
            debugPrint("Login completed")
            completion()
        }
    }
    
    func createChannel(delegate: AgoraRtmChannelDelegate) {
        guard let rtmChannel = kit?.createChannel(withId: "test", delegate: delegate) else {
            debugPrint("Could not create RTM Channel")
            return
        }
        rtmChannel.channelDelegate = delegate
        rtmChannel.join { [weak self] (error) in
            if error != .channelErrorOk, let strongSelf = self {
                debugPrint("Error Joining RTM Channel: \(error.rawValue)")
            }
        }
        self.rtmChannel = rtmChannel
    }
    
    func logout() {
        kit?.logout(completion: { (error) in
            guard error == .ok else {
                return
            }
        })
    }
    
    func send(message: Message, _ completion: @escaping (Bool) -> Void) {
        let rtmMessage = AgoraRtmMessage(text: message.message)
        
        rtmChannel?.send(rtmMessage) { (error) in
            let sent = error == .errorOk ? true : false
            completion(sent)
        }
    }
    
    func messageReceived(message: Message) {
        view?.messageReceived(message: message)
    }
}


