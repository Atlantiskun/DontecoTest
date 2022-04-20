//
//  ViewController.swift
//  DontecoTest
//
//  Created by Дмитрий Болучевских on 18.04.2022.
//

import UIKit
import MediaPlayer
import SnapKit

class MainViewController: UIViewController {
    private var mediaPicker: MPMediaPickerController?
    private var lastButtonPressed = 0
    private var firstTrack: MPMediaItem?
    private var secondTrack: MPMediaItem?
    
    private var currentFade: Double = 2
    private var maxFade: Double = 10
    
    private var wasProcessed: Bool = false
    private var nowIsPlaying: Bool = false
    
    // MARK: - Interface's elements initialization
    private let trackImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "music.note", withConfiguration: UIImage.SymbolConfiguration(pointSize: 120, weight: .light, scale: .small))
        image.backgroundColor = backgroundArtwork
        image.tintColor = placeholderColor
        image.contentMode = .center
        return image
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Track name"
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 22)
        return label
    }()
    
    private let trackArtistLabel: UILabel = {
        let label = UILabel()
        label.text = "Artist name"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = buttonsDefaultColor
        button.addTarget(self, action: #selector(playMusic), for: .touchUpInside)
        return button
    }()
    
    private let choseFirstTrack: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "1.square"), for: .normal)
        button.tintColor = buttonsDefaultColor
        button.tag = 1
        button.addTarget(self, action: #selector(chooseTrack), for: .touchUpInside)
        return button
    }()
    
    private let choseSecondTrack: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "2.square"), for: .normal)
        button.tintColor = buttonsDefaultColor
        button.tag = 2
        button.addTarget(self, action: #selector(chooseTrack), for: .touchUpInside)
        return button
    }()
    
    private var crossfadeSliderController: UISlider = {
        let slider = UISlider()
        slider.value = 0.2
        slider.minimumValue = 0.2
        slider.maximumValue = 1.0
        slider.tintColor = buttonsDefaultColor
        slider.addTarget(self, action: #selector(changeСrossfadeSliderValue), for: .valueChanged)
        return slider
    }()
    
    private let crossfadeSliderValue: UILabel = {
        let label = UILabel()
        label.text = "Crossdafe is 2 sec"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    // MARK: - Button's actions
    @objc private func changeСrossfadeSliderValue(_ sender: UISlider) {
        currentFade = Double(sender.value * 10).rounded()
        crossfadeSliderValue.text = "Crossdafe is \(Int(currentFade)) sec"
    }
    
    @objc private func chooseTrack(_ sender: UIButton) {
        mediaPicker = MPMediaPickerController.self(mediaTypes: .music)
        mediaPicker?.allowsPickingMultipleItems = false
        mediaPicker?.delegate = self
        lastButtonPressed = sender.tag
        
        present(mediaPicker!, animated: true, completion: nil)
    }
    
    @objc private func playMusic(_ sender: UIButton) {
        if !wasProcessed {
            if let track1 = firstTrack,
               let track2 = secondTrack {
                if maxFade >= currentFade {
                    PlayerManager.shared.setupFade(for: [track1, track2], withFadeDuration: currentFade)
                    wasProcessed = true
                    
                    PlayerManager.shared.playPauseMusic(nowIsPlaying)
                    changePlayPauseButton()
                } else {
                    callAlertFadeValue()
                }
            } else {
                callAlertEmptyTrack()
            }
        }
        else {
            PlayerManager.shared.playPauseMusic(nowIsPlaying)
            changePlayPauseButton()
        }
    }
    
    // MARK: - Buttons modifications
    private func changePlayPauseButton() {
        nowIsPlaying.toggle()
        if nowIsPlaying {
            playPauseButton.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        } else {
            playPauseButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        }
    }
    
    private func changeChooseTrackButton(withTag: Int, andHasProtected: Bool) {
        for elem in view.subviews where elem.tag == withTag {
            if let button = elem as? UIButton {
                if andHasProtected {
                    button.tintColor = buttonDeclainColor
                } else {
                    button.tintColor = buttonConfirmColor
                }
            }
        }
    }
    
    private func changeChooseTrackButton() {
        for elem in view.subviews where elem.tag != 0 {
            if let button = elem as? UIButton,
               button.tag == 1,
                firstTrack == nil {
                button.tintColor = buttonDeclainColor
            }
            
            if let button = elem as? UIButton,
               button.tag == 2,
                secondTrack == nil {
                button.tintColor = buttonDeclainColor
            }
        }
    }
    
    // MARK: - Observer for update current track's info when start play
    private lazy var changed = PlayerManager.shared.$playingCopy.sink { newIsSecond in
        self.playingSecondTrack = newIsSecond
    }
    
    private var playingSecondTrack: Bool = false {
        didSet {
            if playingSecondTrack,
               secondTrack != nil {
                setupView(with: secondTrack)
            } else if !playingSecondTrack,
                      firstTrack != nil {
                setupView(with: firstTrack)
            }
        }
    }
    
    private func setupView(with track: MPMediaItem? = nil) {
        guard let track = track else {
            if lastButtonPressed == 1 {
                trackNameLabel.text = ""
                trackArtistLabel.text = ""
            }
            return
        }
        
        if let image = track.artwork?.image(at: trackImage.frame.size) {
            trackImage.image = image
            trackImage.contentMode = .scaleAspectFill
            trackImage.backgroundColor = backgorundColor
        } else {
            trackImage.image = UIImage(systemName: "music.quarternote.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 120, weight: .light, scale: .small))
            trackImage.contentMode = .center
            trackImage.backgroundColor = backgroundArtwork
        }
        
        trackNameLabel.text = track.title ?? "Track name data is empty"
        trackArtistLabel.text = track.artist ?? "Artist data is empty"
    }
    
    // MARK: - Alerts
    private func callAlertProtected() {
        let alertProtected = UIAlertController(title: "Uhh...", message: "This track is copyrighted, you need to choose another", preferredStyle: .alert)
        alertProtected.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertProtected.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            guard let strongSelf = self else {
                return
            }
            
            switch action.style {
            case .default:
                let button = UIButton()
                button.tag = strongSelf.lastButtonPressed
                strongSelf.chooseTrack(button)
            default:
                break
            }
        }))
        present(alertProtected, animated: true)
    }
    
    private func callAlertFadeValue() {
        let alertProtected = UIAlertController(title: "Hmm...", message: "You should chose crossfade beetween 2 and \(Int(maxFade)) for current tracks", preferredStyle: .alert)
        alertProtected.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.currentFade = strongSelf.maxFade
            strongSelf.crossfadeSliderController.setValue(Float(strongSelf.maxFade / 10) + 0.04, animated: true)
            strongSelf.changeСrossfadeSliderValue(strongSelf.crossfadeSliderController)
        }))
        present(alertProtected, animated: true)
    }
    
    private func callAlertEmptyTrack() {
        let alertProtected = UIAlertController(title: "Well...", message: "You should chose both track to work with crossfade", preferredStyle: .alert)
        alertProtected.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertProtected, animated: true)
        changeChooseTrackButton()
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgorundColor
        var _ = changed
    }
    
    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setups()
        
    }
    
    private func setups() {
        view.addSubview(trackImage)
        trackImage.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(view.snp.width).multipliedBy(0.8)
            make.top.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(trackNameLabel)
        trackNameLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(70)
            make.top.equalTo(trackImage.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(trackArtistLabel)
        trackArtistLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(20)
            make.top.equalTo(trackNameLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(playPauseButton)
        playPauseButton.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(trackArtistLabel.snp.bottom).offset(40)
        }
        
        view.addSubview(choseFirstTrack)
        choseFirstTrack.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.centerX.equalTo(playPauseButton.snp.centerX).offset(-100)
            make.top.equalTo(trackArtistLabel.snp.bottom).offset(40)
        }
        
        view.addSubview(choseSecondTrack)
        choseSecondTrack.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.centerX.equalTo(playPauseButton.snp.centerX).offset(100)
            make.top.equalTo(trackArtistLabel.snp.bottom).offset(40)
        }
        
        view.addSubview(crossfadeSliderController)
        crossfadeSliderController.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.top.equalTo(playPauseButton.snp.bottom).offset(50)
        }
        
        view.addSubview(crossfadeSliderValue)
        crossfadeSliderValue.snp.makeConstraints { make in
            make.width.equalTo(180)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(crossfadeSliderController.snp.bottom).offset(30)
        }
    }
}

// MARK: - Audiofile Picker Delegate methods
extension MainViewController: MPMediaPickerControllerDelegate {
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        self.dismiss(animated: true, completion: nil)
        if let track = mediaItemCollection.items.first {
            if lastButtonPressed == 1 {
                if track.hasProtectedAsset {
                    firstTrack = nil
                    callAlertProtected()
                } else {
                    firstTrack = track
                    let localMaxFade = Double((track.playbackDuration / 2).rounded(.down))
                    maxFade = localMaxFade < maxFade ? localMaxFade : maxFade
                }
                setupView(with: firstTrack)
                changeChooseTrackButton(withTag: lastButtonPressed, andHasProtected: track.hasProtectedAsset)
            } else {
                if track.hasProtectedAsset {
                    secondTrack = nil
                    callAlertProtected()
                } else {
                    secondTrack = track
                    let localMaxFade = Double((track.playbackDuration / 2).rounded(.down))
                    maxFade = localMaxFade < maxFade ? localMaxFade : maxFade
                }
                if firstTrack == nil {
                    setupView(with: secondTrack)
                }
                changeChooseTrackButton(withTag: lastButtonPressed, andHasProtected: track.hasProtectedAsset)
            }
        }
    }
}

