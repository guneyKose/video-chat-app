//
//  VideoCallViewController.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//

import UIKit
import SnapKit
import AgoraRtcKit

class VideoCallViewController: UIViewController {
   
    var localView: UIView!
    var remoteView: UIView!
    var loadingIcon: UIActivityIndicatorView!
    var controlView: UIView!
    var micButton: UIButton!
    var camButton: UIButton!
    var endCallButton: UIButton!
    var switchCameraButton: UIButton!
    var buttonStack: UIStackView!
    
    let camOnImage = UIImage(systemName: "video.fill")
    let camOffImage = UIImage(systemName: "video.slash.fill")
    
    let micOnImage = UIImage(systemName: "mic.fill")
    let micOffImage = UIImage(systemName: "mic.slash.fill")
    
    let viewModel = VideoCallViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.initializeAgoraEngine()
        self.setupLocalVideo()
        self.joinChannel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.leaveChannel()
    }
    
    private func setupUI() {
        remoteView = UIView(frame: view.frame)
        localView = UIView()
        loadingIcon = UIActivityIndicatorView()
        controlView = UIView()
        buttonStack = UIStackView()
        micButton = UIButton()
        endCallButton = UIButton()
        camButton = UIButton()
        switchCameraButton = UIButton()
        
        view.addSubview(remoteView)
        view.addSubview(localView)
        remoteView.addSubview(loadingIcon)
        remoteView.addSubview(controlView)
        controlView.addSubview(buttonStack)
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
        loadingIcon.color = .black
        loadingIcon.center = remoteView.center
        loadingIcon.startAnimating()
        
        setupButtons()
        
        controlView.layer.cornerRadius = 20
        controlView.backgroundColor = .black.withAlphaComponent(0.5)
        
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
    }
    
    private func createConstraints() {
        localView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width / 3)
            make.height.equalTo(view.frame.width / 2.5)
            make.top.equalTo(view.snp.top).offset(100)
            make.right.equalTo(view.snp.right).offset(-12)
        }
        
        controlView.snp.makeConstraints { make in
            make.width.equalTo(remoteView)
            make.height.equalTo(150)
            make.bottom.equalTo(remoteView.snp.bottom)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width - 48)
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
    }
    
    private func setupButtons() {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.cornerStyle = .capsule
        
        camButton.configuration = buttonConfig
        switchCameraButton.configuration = buttonConfig
        micButton.configuration = buttonConfig
        endCallButton.configuration = buttonConfig
        
        camButton.tintColor = .white
        switchCameraButton.tintColor = .white
        micButton.tintColor = .white
        endCallButton.tintColor = .red
        
        camButton.setImage(camOnImage, for: .normal)
        switchCameraButton.setImage(UIImage(systemName: "camera.rotate.fill"), for: .normal)
        micButton.setImage(micOnImage, for: .normal)
        endCallButton.setImage(UIImage(systemName: "phone.down.fill"), for: .normal)
        
        camButton.addTarget(self, action: #selector(toggleCamera), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        micButton.addTarget(self, action: #selector(toggleMic), for: .touchUpInside)
        endCallButton.addTarget(self, action: #selector(endCall), for: .touchUpInside)
    }
    
    @objc func toggleCamera() {
        if viewModel.isCameraEnabled {
            viewModel.agoraEngine.disableVideo()
            camButton.setImage(camOffImage, for: .normal)
        } else {
            viewModel.agoraEngine.enableVideo()
            camButton.setImage(camOnImage, for: .normal)
        }
        viewModel.isCameraEnabled.toggle()
    }
    
    @objc func switchCamera() {
        viewModel.agoraEngine.switchCamera()
    }
    
    @objc func toggleMic() {
        if viewModel.isMicOn {
            viewModel.agoraEngine.disableAudio()
            micButton.setImage(micOffImage, for: .normal)
        } else {
            viewModel.agoraEngine.enableAudio()
            micButton.setImage(micOnImage, for: .normal)
        }
        viewModel.isMicOn.toggle()
    }
    
    @objc func endCall() {
        leaveChannel()
        navigationController?.popViewController(animated: true)
    }
}
