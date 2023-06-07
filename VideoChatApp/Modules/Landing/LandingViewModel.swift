//
//  LandingViewModel.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import Foundation

protocol LandingViewModelProtocol {
    var pageTitle: String { get }
    var titleText: String { get }
    var placeholderText: String { get }
    var buttonTitle: String { get }
}

final class LandingViewModel: LandingViewModelProtocol {
    let pageTitle: String
    let titleText: String
    let placeholderText: String
    let buttonTitle: String
    
    init() {
        pageTitle = "Hello"
        titleText = "Enter your username"
        placeholderText = "Username"
        buttonTitle = "Start Call"
    }
}

