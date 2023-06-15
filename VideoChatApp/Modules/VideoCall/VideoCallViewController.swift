//
//  VideoCallViewController.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import UIKit
import SnapKit
import AgoraRtcKit

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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(viewModel: VideoCallViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.viewModel.view = self
        self.viewModel.agoraManager.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.onViewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.onViewDidDisappear()
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
        
        view.addSubview(remoteView)
        view.addSubview(localView)
        view.addSubview(controlView)
        view.addSubview(messageInputBar)
        remoteView.addSubview(loadingIcon)
        remoteView.addSubview(informUserLabel)
        remoteView.addSubview(chatTableView)
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
        
        chatTableView.backgroundColor = .red
        chatTableView.isHidden = true
        messageInputBar.isHidden = true
        
        self.viewModel.agoraManager.localView = localView
        self.viewModel.agoraManager.remoteView = remoteView
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
            make.bottom.equalTo(controlView.snp.top).offset(-24)
        }
        
        chatTableView.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(200)
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalTo(messageInputBar.snp.top)
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
        viewModel.agoraManager.toggleCamera()
    }
    
    @objc func switchCamera() {
        viewModel.agoraManager.switchCamera()
    }
    
    @objc func toggleMic() {
        viewModel.agoraManager.toggleMic()
    }
    
    @objc func messageTapped() {
        viewModel.messageTapped()
        messageInputBar.chatTextField.becomeFirstResponder()
    }
}

extension VideoCallViewController: VideoCallView {
    @objc func endCall() {
        viewModel.onViewDidDisappear()
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
        chatTableView.isHidden = !open
        messageInputBar.isHidden = !open
    }
}

//MARK: - AgoraDelegate
extension VideoCallViewController: AgoraRtcEngineDelegate {
    
    // Callback called when a new host joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        viewModel.agoraManager.didJoinedOfUid(uid: uid)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteReason, elapsed: Int) {
        viewModel.agoraManager.remoteVideoStatusChanged(state)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt, state: AgoraAudioRemoteState, reason: AgoraAudioRemoteReason, elapsed: Int) {
        viewModel.agoraManager.remoteAudioStatusChanged(state)
    }
    
    //When remote user leaves the channel.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
            endCall()
    }
}
