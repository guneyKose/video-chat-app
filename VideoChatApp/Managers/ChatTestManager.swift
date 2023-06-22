//
//  ChatTestManager.swift
//  VideoChatApp
//
//  Created by Güney Köse on 20.06.2023.
//

import Foundation
import AgoraRtmKit

class ChatManagerTestImpl: NSObject, ChatManager {
    weak var view: VideoCallView?
    var rtmChannel: AgoraRtmChannel?
    var kit: AgoraRtmKit?
    var timer: Timer?
    
    init(view: VideoCallView? = nil, rtmChannel: AgoraRtmChannel? = nil, kit: AgoraRtmKit? = nil, timer: Timer? = nil) {
        self.view = view
        self.rtmChannel = rtmChannel
        self.kit = kit
        self.timer = timer
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
        
        timer = Timer.scheduledTimer(withTimeInterval: 4.9, repeats: true) { timer in
            let sender = AgoraRtmMember()
            sender.userId = "jesus"
            let rtmMessage = AgoraRtmMessage(text: "who dis?")
            self.channel(rtmChannel, messageReceived: rtmMessage, from: sender)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.view?.sendMessage(message: "hello!")
            })
        }
    }
    
    func logout() {
        kit?.logout(completion: { (error) in
            guard error == .ok else {
                return
            }
        })
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func send(message: Message, _ completion: @escaping (Bool) -> Void) {
        let rtmMessage = AgoraRtmMessage(text: message.message)
        
        rtmChannel?.send(rtmMessage) { (error) in
            let sent = error == .errorOk ? true : true
            completion(sent)
        }
    }
    
    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        let message = Message(username: member.userId, message: message.text)
        view?.messageReceived(message: message)
    }
}
