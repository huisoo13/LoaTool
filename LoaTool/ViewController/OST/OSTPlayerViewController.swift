//
//  OSTPlayerViewController.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/11/08.
//

/*
 AVAudioEngine
 : Use a group of connected audio node objects to generate and process audio signals and perform audio input and output.
 : 연결된 오디오 노드 개체 그룹을 사용하여 오디오 신호를 생성 및 처리하고 오디오 입력 및 출력을 수행합니다.
 
 // TODO: 위 클래스로 에어팟의 연결 상태를 받아와 조정 할 수 있는지 확인하기
 */

/*
 // TODO: 커버이미지에 따라 다른 색상 불러오기
 UIImageColors
 : 이미지 색상 추출 라이브러리
 https://github.com/jathu/UIImageColors
 */

/*
 https://github.com/xxxAIRINxxx/MusicAppTransition
 https://www.kodeco.com/221-recreating-the-apple-music-now-playing-transition
 */

import UIKit
import AVFoundation

class OSTPlayerViewController: UIViewController, Storyboarded {
    weak var coordinator: AppCoordinator?

    var playerQueue: AVQueuePlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // setupAudioPlayer()
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

extension OSTPlayerViewController {

}
