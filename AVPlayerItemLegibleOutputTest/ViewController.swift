//
//  ViewController.swift
//  AVPlayerItemLegibleOutputTest
//
//  Created by Tamás Zahola on 2019. 05. 02..
//  Copyright © 2019. Tamás Zahola. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerView: UIView {
    override class var layerClass: AnyClass { return AVPlayerLayer.self }
}

class ViewController: UIViewController {

    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var subtitleView: UIVisualEffectView!
    @IBOutlet weak var subtitleLabel: UILabel!


    var player: AVPlayer!
    var legibleOutput: AVPlayerItemLegibleOutput!
    var item: AVPlayerItem!
    var itemStatusKVOToken: NSKeyValueObservation!
    var composition: AVMutableComposition!

    override func viewDidLoad() {
        super.viewDidLoad()

        subtitleView.clipsToBounds = true
        subtitleView.layer.cornerRadius = 8

        showSubtitle("")
    }

    private func start(with videoURL: URL) {
        player = nil
        legibleOutput = nil
        itemStatusKVOToken = nil
        item = nil
        composition = nil

        composition = AVMutableComposition()

        let videoAsset = AVAsset(url: videoURL)

        let videoTrack = videoAsset.tracks(withMediaType: .video).first!
        let composedVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        try! composedVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoTrack, at: .zero)

        let subtitleAsset = AVAsset(url: Bundle.main.url(forResource: "subtitles", withExtension: "webvtt")!)
        let subtitleTrack = subtitleAsset.tracks(withMediaType: .text).first!
        let composedSubtitleTrack = composition.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)!
        try! composedSubtitleTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: subtitleTrack, at: .zero)

        item = AVPlayerItem(asset: composition, automaticallyLoadedAssetKeys: [#keyPath(AVPlayerItem.duration)])
        legibleOutput = AVPlayerItemLegibleOutput()
        legibleOutput.setDelegate(self, queue: DispatchQueue.main)
        legibleOutput.suppressesPlayerRendering = true
        item.add(legibleOutput)

        player = AVPlayer(playerItem: item)
        player.seek(to: CMTime(seconds: 0.5, preferredTimescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()

        (playerView.layer as! AVPlayerLayer).player = player
    }

    @IBAction func start480p(_ sender: Any) {
        start(with: Bundle.main.url(forResource: "video_480p", withExtension: "mp4")!)
    }

    @IBAction func start1024p(_ sender: Any) {
        start(with: Bundle.main.url(forResource: "video_1024p", withExtension: "mp4")!)
    }
}

extension ViewController: AVPlayerItemLegibleOutputPushDelegate {

    func legibleOutput(_ output: AVPlayerItemLegibleOutput,
                       didOutputAttributedStrings strings: [NSAttributedString],
                       nativeSampleBuffers nativeSamples: [Any],
                       forItemTime itemTime: CMTime) {
        showSubtitle(strings.reduce("", { $0 + ($0.isEmpty ? "" : "\n") + $1.string }))
    }

    func outputSequenceWasFlushed(_ output: AVPlayerItemOutput) {
        showSubtitle("")
    }

    func showSubtitle(_ subtitle: String) {
        subtitleLabel.text = subtitle
        subtitleView.isHidden  = subtitle.isEmpty
    }
}

