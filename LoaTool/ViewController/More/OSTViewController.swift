//
//  OSTViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/11/02.
//

/*
 AVAudioEngine
 : Use a group of connected audio node objects to generate and process audio signals and perform audio input and output.
 : 연결된 오디오 노드 개체 그룹을 사용하여 오디오 신호를 생성 및 처리하고 오디오 입력 및 출력을 수행합니다.
 
 TODO: 위 클래스로 에어팟의 연결 상태를 받아와 조정 할 수 있는지 확인하기
 */


import UIKit
import AVFoundation

class OSTViewController: UIViewController, Storyboarded {
    weak var coordinator: AppCoordinator?

    var playerQueue: AVQueuePlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupAudioPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        playerQueue?.pause()
    }
    
    func setupAudioPlayer() {
        let fileURL = URL(string: "https://cdn-lostark.game.onstove.com/uploadfiles/ost/vol3_15_Oe%20e%20hoomanao.mp3")!
        let avAsset = AVAsset(url: fileURL)
        let assetKeys = ["playable"]
        let playerItem = AVPlayerItem(asset: avAsset, automaticallyLoadedAssetKeys: assetKeys)
        playerQueue = AVQueuePlayer(items: [playerItem])
        playerQueue?.play()
    }
}

extension OSTViewController {
    fileprivate func setupNavigationBar() {
        setTitle("OST".localized, size: 20)
    }
}

