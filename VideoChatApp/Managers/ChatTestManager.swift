//
//  ChatTestManager.swift
//  VideoChatApp
//
//  Created by Güney Köse on 20.06.2023.
//

import Foundation
import AgoraRtmKit

class ChatManagerTestImpl: ChatManager {
    weak var view: VideoCallView?
    var rtmChannel: AgoraRtmChannel?
    var kit: AgoraRtmKit?
    var timer: Timer?
    
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 4.9, repeats: true) { timer in
            let message = Message(username: "jesus", message: "who dis?")
            self.messageReceived(message: message)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                let msg = Message(username: "steve", message: "hello!")
                self.view?.sendMessage(message: msg.message)
            })
        }
    }
    
    deinit {
        debugPrint("deinit works")
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
    
    func messageReceived(message: Message) {
        debugPrint("messageReceived")
        view?.messageReceived(message: message)
    }
}
