//
//  RhythmViewController.swift
//  Cello Mute
//
//  Created by William Ma on 12/28/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit

protocol RhythmViewControllerDelegate: AnyObject {

    func rhythmViewController(_ rhythmViewController: RhythmViewController, rhythmDidChange rhythm: Rhythm)

}

class RhythmViewController: UIViewController {

    weak var delegate: RhythmViewControllerDelegate?

    var highlightedBeat: Int? {
        get { return beatStylesView.highlightedBeat }
        set { beatStylesView.highlightedBeat = newValue }
    }

    var rhythm: Rhythm {
        get {
            return Rhythm(beatStyles: beatStyles, subdivisionLevel: subdivisionLevel)!
        }
        set {
            subdivisionLevel = newValue.subdivisionLevel
            beatCount = newValue.beatStyles.count

            for (i, beatStyle) in newValue.beatStyles.enumerated() {
                persistedBeatStyles[i] = beatStyle
            }

            updateViewsFromModel()
        }
    }

    private var subdivisionLevel: Int = 1
    private var beatCount: Int = 4
    private var persistedBeatStyles = [Rhythm.BeatStyle](repeating: .normal, count: 8)

    private var beatStyles: [Rhythm.BeatStyle] {
        return Array(persistedBeatStyles[..<beatCount])
    }

    @IBOutlet private weak var subdivisionLevelSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var beatCountSlider: SegmentedSlider!
    @IBOutlet private weak var beatStylesView: BeatStylesView!

    override func viewDidLoad() {
        super.viewDidLoad()

        beatCountSlider.delegate = self
        beatStylesView.delegate = self

        updateViewsFromModel()
    }

    @IBAction private func subdivisionLevelValueChanged() {
        let newValue = subdivisionLevelSegmentedControl.selectedSegmentIndex + 1

        guard 1 <= newValue, newValue <= 4 else {
            print("Attempted to set subdivision level to invalid value: \(newValue)")
            return
        }

        subdivisionLevel = newValue

        delegate?.rhythmViewController(self, rhythmDidChange: rhythm)
    }

    private func updateViewsFromModel() {
        subdivisionLevelSegmentedControl.selectedSegmentIndex = subdivisionLevel - 1
        beatCountSlider.segment = beatCount - 1
        beatStylesView.beatStyles = beatStyles
    }

}

extension RhythmViewController: SegmentedSliderDelegate {

    func segmentedSlider(_ segmentedSlider: SegmentedSlider, segmentDidChange segment: Int) {
        let newBeatCount = segment + 1
        guard newBeatCount != beatCount else {
            return
        }

        guard 1 <= newBeatCount, newBeatCount <= 8 else {
            print("Attempted to set visible beats to invalid value: \(newBeatCount)")
            return
        }

        beatCount = newBeatCount

        beatStylesView.beatStyles = beatStyles

        delegate?.rhythmViewController(self, rhythmDidChange: rhythm)
    }

}

extension RhythmViewController: BeatStylesViewDelegate {

    func beatStylesView(_ beatStylesView: BeatStylesView, beatStylesDidChange newBeatStyles: [Rhythm.BeatStyle]) {
        for (i, beatStyle) in newBeatStyles.enumerated() {
            persistedBeatStyles[i] = beatStyle
        }

        delegate?.rhythmViewController(self, rhythmDidChange: rhythm)
    }

}
