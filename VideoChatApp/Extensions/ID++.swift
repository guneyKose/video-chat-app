//
//  ID++.swift
//  VideoChatApp
//
//  Created by Güney Köse on 8.06.2023.
//

import Foundation
import UIKit

extension UIViewController {
    static var id: String {
        return String(describing: self)
    }
}
