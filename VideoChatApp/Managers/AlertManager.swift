//
//  AlertManager.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation
import UIKit

enum AlertManager {
    case enterUsername, tooShort
    
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
        }
    }
}


