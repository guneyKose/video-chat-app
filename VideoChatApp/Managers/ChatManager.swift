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
    var current: String? { get set }
    
    func login(username: String, delegate: AgoraRtmDelegate)
    func logout()
    func send(message: Message)
}

class ChatManagerImpl: ChatManager {
    weak var view: VideoCallView?
    var kit: AgoraRtmKit?
    var current: String?
    
    init() {
        
    }
    
    func login(username: String, delegate: AgoraRtmDelegate) {
        current = username
        kit = AgoraRtmKit(appId: agoraAppID, delegate: delegate)
        kit?.agoraRtmDelegate = delegate
        kit?.login(byToken: nil, user: username) { [unowned self] (errorCode) in
            guard errorCode == .ok else {
                debugPrint("Login Error Code: ", errorCode)
                return
            }
        }
    }
    
    func logout() {
        kit?.logout(completion: { (error) in
            guard error == .ok else {
                return
            }
        })
    }
    
    func send(message: Message) {
        let rtmMessage = AgoraRtmMessage(text: message.message)
        
        let option = AgoraRtmSendMessageOptions()
        
        kit?.send(rtmMessage, toPeer: "guney", sendMessageOptions: option, completion: { (error) in
            debugPrint("Message send error: \(error.rawValue)")
        })
    }
}


