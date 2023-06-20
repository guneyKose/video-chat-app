//
//  VideoCallViewController.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import UIKit
import SnapKit

enum ButtonIconType {
    case micOn, micOff, videoOn, videoOff
    
    var icon: UIImage? {
        switch self {
        case .micOn:
            return UIImage(systemName: "mic.fill")
        case .micOff:
            return UIImage(systemName: "mic.slash.fill")
        case .videoOn:
            return UIImage(systemName: "video.fill")
        case .videoOff:
            return UIImage(systemName: "video.slash.fill")
        }
    }
}

protocol VideoCallView: AnyObject {
    func endCall()
    func changeButtonIcons(mic: ButtonIconType?, video: ButtonIconType?)
    func toggleKeyboard(_ open: Bool)
    func keyboardDidDismiss()
    func keyboardDidShown()
    func sendMessage(message: String)
    func messageReceived(message: Message)
    func hideChat(_ hide: Bool)
    func reloadChat()
}

class VideoCallViewController: UIViewController {
    
    var viewModel: VideoCallViewModel!
   
    var localView: UIView!
    var remoteView: UIView!
    var loadingIcon: UIActivityIndicatorView!
    var controlView: UIView!
    var micButton: UIButton!
    var camButton: UIButton!
    var messageButton: UIButton!
    var endCallButton: UIButton!
    var switchCameraButton: UIButton!
    var buttonStack: UIStackView!
    var informUserLabel: UILabel!
    var chatTableView: UITableView!
    var messageInputBar: MessageInputBar!
    var keyboardHeight: CGFloat?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(viewModel: VideoCallViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.viewModel.view = self
        self.viewModel.videoCallManager.view = self
        self.viewModel.chatManager.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.onViewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.endCall()
    }
    
    private func setupUI() {
        remoteView = UIView()
        localView = UIView()
        loadingIcon = UIActivityIndicatorView()
        controlView = UIView()
        buttonStack = UIStackView()
        micButton = UIButton()
        endCallButton = UIButton()
        camButton = UIButton()
        switchCameraButton = UIButton()
        informUserLabel = UILabel()
        messageButton = UIButton()
        chatTableView = UITableView()
        messageInputBar = MessageInputBar(frame: .zero)
        
        messageInputBar.view = self
        
        view.addSubview(remoteView)
        view.addSubview(localView)
        view.addSubview(controlView)
        view.addSubview(messageInputBar)
        view.addSubview(chatTableView)
        remoteView.addSubview(loadingIcon)
        remoteView.addSubview(informUserLabel)
        controlView.addSubview(buttonStack)
        buttonStack.addArrangedSubview(messageButton)
        buttonStack.addArrangedSubview(camButton)
        buttonStack.addArrangedSubview(switchCameraButton)
        buttonStack.addArrangedSubview(micButton)
        buttonStack.addArrangedSubview(endCallButton)
        
        remoteView.center = view.center
        
        createConstraints()
        
        localView.layer.cornerRadius = 10
        localView.clipsToBounds = true
        localView.makeDraggable()
        loadingIcon.style = .large
        loadingIcon.color = .label
        loadingIcon.center = remoteView.center
        loadingIcon.startAnimating()
        
        setupButtons()
        
        controlView.layer.cornerRadius = 20
        controlView.backgroundColor = .black.withAlphaComponent(0.5)
        
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        
        informUserLabel.textColor = .label
        informUserLabel.textAlignment = .center
        informUserLabel.text = "Waiting for the other user..."
        
        chatTableView.isHidden = true
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.backgroundColor = .systemBackground.withAlphaComponent(0.25)
        chatTableView.layer.cornerRadius = 8
        chatTableView.showsVerticalScrollIndicator = false
        chatTableView.separatorStyle = .none
        messageInputBar.isHidden = true
        chatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatTableViewCell")
        
        self.viewModel.videoCallManager.localView = localView
        self.viewModel.videoCallManager.remoteView = remoteView
    }
    
    private func createConstraints() {
        remoteView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        localView.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(3)
            make.height.equalTo(localView.snp.width).multipliedBy(1.33)
            make.top.equalTo(view.snp.top).offset(100)
            make.right.equalTo(view.snp.right).offset(-12)
        }
        
        controlView.snp.makeConstraints { make in
            make.width.equalTo(remoteView)
            make.height.equalTo(150)
            make.bottom.equalTo(remoteView.snp.bottom)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(100)
            make.center.equalTo(controlView)
        }
        
        micButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        switchCameraButton.snp.makeConstraints { make in
            make.size.equalTo(micButton)
        }
        
        camButton.snp.makeConstraints { make in
            make.size.equalTo(micButton)
        }
        
        endCallButton.snp.makeConstraints { make in
            make.size.equalTo(camButton)
        }
        
        messageButton.snp.makeConstraints { make in
            make.size.equalTo(endCallButton)
        }
        
        informUserLabel.snp.makeConstraints { make in
            make.top.equalTo(loadingIcon.snp.bottom).offset(30)
            make.width.equalToSuperview()
        }
        
        messageInputBar.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-(keyboardHeight ?? 0))
        }
        
        chatTableView.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(200)
            make.leading.equalToSuperview()
            make.centerY.equalTo(messageInputBar).offset(-125)
        }
    }
    
    func setupButtons() {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.cornerStyle = .capsule
        
        camButton.configuration = buttonConfig
        switchCameraButton.configuration = buttonConfig
        micButton.configuration = buttonConfig
        endCallButton.configuration = buttonConfig
        messageButton.configuration = buttonConfig
        
        camButton.tintColor = .white
        switchCameraButton.tintColor = .white
        micButton.tintColor = .white
        endCallButton.tintColor = .red
        messageButton.tintColor = .white
        
        let switchCamImage = UIImage(systemName: "camera.rotate.fill")
        let endCallImage = UIImage(systemName: "phone.down.fill")
        let messageImage = UIImage(systemName: "message.fill")
        
        switchCameraButton.setImage(switchCamImage, for: .normal)
        endCallButton.setImage(endCallImage, for: .normal)
        messageButton.setImage(messageImage, for: .normal)
        
        changeButtonIcons(mic: .micOn, video: .videoOn)
        
        camButton.addTarget(self, action: #selector(toggleCamera), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        micButton.addTarget(self, action: #selector(toggleMic), for: .touchUpInside)
        endCallButton.addTarget(self, action: #selector(endCall), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(messageTapped), for: .touchUpInside)
    }
    
    //MARK: - Button Actions
    @objc func toggleCamera() {
        viewModel.videoCallManager.toggleCamera()
    }
    
    @objc func switchCamera() {
        viewModel.videoCallManager.switchCamera()
    }
    
    @objc func toggleMic() {
        viewModel.videoCallManager.toggleMic()
    }
    
    @objc func messageTapped() {
        viewModel.messageTapped()
        messageInputBar.chatTextField.becomeFirstResponder()
    }
}

extension VideoCallViewController: VideoCallView {
    
    @objc func endCall() {
        viewModel.endCall()
        navigationController?.popViewController(animated: true)
    }
    
    func changeButtonIcons(mic: ButtonIconType?, video: ButtonIconType?) {
        if let micIcon = mic?.icon {
            micButton.setImage(micIcon, for: .normal)
        }
        if let videoIcon = video?.icon {
            camButton.setImage(videoIcon, for: .normal)
        }
    }
    
    func toggleKeyboard(_ open: Bool) {
        messageInputBar.isHidden = !open
        viewModel.isMessageInputOpen = open
        if open {
            chatTableView.isHidden = false
            chatTableView.center = CGPoint(x: chatTableView.center.x,
                                           y: messageInputBar.frame.minY - 10 - chatTableView.frame.height / 2)
            
        } else {
            chatTableView.center = CGPoint(x: chatTableView.center.x,
                                           y: controlView.frame.minY - 10 - chatTableView.frame.height / 2)
        }
        UIView.animate(withDuration: 0.2) {
            self.chatTableView.layoutIfNeeded()
        }
    }
    
    func keyboardDidDismiss() {
        toggleKeyboard(false)
    }
    
    func keyboardDidShown() {
        toggleKeyboard(true)
    }
    
    func sendMessage(message: String) {
        viewModel.sendMessage(message)
    }
    
    func messageReceived(message: Message) {
        viewModel.messageReceived(message)
    }
    
    func hideChat(_ hide: Bool) {
        chatTableView.isHidden = hide
        viewModel.isChatVisible = !hide
    }
    
    func reloadChat() {
        chatTableView.reloadData()
        chatTableView.scrollToRow(
            at: IndexPath(row: viewModel.messages.count - 1, section: 0),
            at: .bottom, animated: true)
    }
}

extension VideoCallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as? ChatTableViewCell
        else { fatalError("ChatTableViewCell") }
        let message = viewModel.messages[indexPath.row]
        cell.setupCell(message: message)
        return cell
    }
}
