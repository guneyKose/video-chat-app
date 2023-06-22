//
//  ChatManager.swift
//  VideoChatApp
//
//  Created by Güney Köse on 19.06.2023.
//

import Foundation
import AgoraRtmKit

protocol ChatManager: AgoraRtmDelegate, AgoraRtmChannelDelegate {
    var view: VideoCallView? { get set }
    var kit: AgoraRtmKit? { get set }
    var rtmChannel: AgoraRtmChannel? { get set }
    
    func createChannel()
    func login(username: String, _ completion: @escaping () -> Void)
    func logout()
    func send(message: Message, _ completion: @escaping (Bool) -> Void)
}

class ChatManagerImpl: NSObject, ChatManager {
    
    weak var view: VideoCallView?
    var rtmChannel: AgoraRtmChannel?
    var kit: AgoraRtmKit?
    
    init(view: VideoCallView? = nil, rtmChannel: AgoraRtmChannel? = nil, kit: AgoraRtmKit? = nil) {
        self.view = view
        self.rtmChannel = rtmChannel
        self.kit = kit
    }
    
    func login(username: String, _ completion: @escaping () -> Void) {
        kit = AgoraRtmKit(appId: agoraAppID, delegate: self)
        kit?.agoraRtmDelegate = self
        kit?.login(byToken: nil, user: username) { [unowned self] (errorCode) in
            guard errorCode == .ok else {
                debugPrint("Login Error Code: ", errorCode)
                return
            }
            debugPrint("Login completed")
            completion()
        }
    }
    
    func createChannel() {
        guard let rtmChannel = kit?.createChannel(withId: "test", delegate: self) else {
            debugPrint("Could not create RTM Channel")
            return
        }
        rtmChannel.channelDelegate = self
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

    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        let message = Message(username: member.userId, message: message.text)
        view?.messageReceived(message: message)
    }
}


