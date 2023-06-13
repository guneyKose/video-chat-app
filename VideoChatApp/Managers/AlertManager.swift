//
//  AlertManager.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation
import UIKit

enum AlertManager {
    case enterUsername, tooShort, noInternetConnection, needPermission
    
    var alert: UIAlertController {
        switch self {
        case .enterUsername:
            let alert = UIAlertController(
                title: "Enter Username",
                message: "Enter username to start video call.",
                preferredStyle: .alert)
            let action = UIAlertAction(title: "OK",
                                       style: .default)
            alert.addAction(action)
            return alert
        case .tooShort:
            let alert = UIAlertController(
                title: "Username is too short!",
                message: "Username should at least 3 characters long.",
                preferredStyle: .alert)
            let action = UIAlertAction(title: "OK",
                                       style: .default)
            alert.addAction(action)
            return alert
        case .noInternetConnection:
            let alert = UIAlertController(
                title: "You are not connected to the internet!",
                message: "Connect to the internet and try again.",
                preferredStyle: .alert)
            let action = UIAlertAction(title: "OK",
                                       style: .default)
            alert.addAction(action)
            return alert
            
        case .needPermission:
            let alert = UIAlertController(
                title: "Camera and Mic Usage",
                message: "You need to give permission to video chat.",
                preferredStyle: .alert
            )
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            
            return alert
        }
    }
}

