//
//  ChatTableViewCell.swift
//  VideoChatApp
//
//  Created by Güney Köse on 16.06.2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setupCell(message: Message) {
        textLabel?.text = "\(message.username) : \(message.message)"
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    
}
