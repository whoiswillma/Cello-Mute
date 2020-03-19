//
//  TunerViewController.swift
//  Cello Mute
//
//  Created by William Ma on 11/13/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import AudioKit
import SwiftNotificationCenter
import SwiftyUserDefaults
import UIKit

class TunerViewController: UIViewController {

    // views

    @IBOutlet private weak var headerView: TunerHeaderView!
    @IBOutlet private weak var plotView: TunerPlotView!
    @IBOutlet private weak var accuracyView: TunerAccuracyView!

    private var inTuneCentRange: ClosedRange<Int> = -5...5

    private var tuner: Tuner!

    // controller

    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.shared.tunerInitialized = { tuner in
            self.tuner = tuner
            self.tuner.delegate = self

            self.plotView.inputNode = tuner.microphone

            self.reloadSettingsFromDefaults()
            Broadcaster.register(SettingsDefaultsObserving.self, observer: self)

            self.tuner.startTracking()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tuner?.startTracking()

        Warnings.shared.showMicrophoneAccessWarningIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tuner.stopTracking()
    }

}

extension TunerViewController: TunerDelegate {

    func tunerDidStartTracking(_ tuner: Tuner) {
        print("Tuner started tracking")
    }

    func tunerDidStopTracking(_ tuner: Tuner) {
        print("Tuner stopped tracking")

        headerView.trackingStatus = .notTracking
        accuracyView.setCentOffset(nil, animated: true)
    }

    func tunerDidBeginInactivelyTracking(_ tuner: Tuner) {
        headerView.trackingStatus = .inactivelyTracking
    }

    func tunerDidEndInactivelyTracking(_ tuner: Tuner) {
    }

    func tunerDidBeginActivelyTracking(_ tuner: Tuner) {
        headerView.trackingStatus = .activelyTracking
    }

    func tunerDidEndActivelyTracking(_ tuner: Tuner) {
        plotView.pitch = nil
        accuracyView.setCentOffset(nil, animated: true)
    }

    func tuner(_ tuner: Tuner, didSampleSoundAtPitch pitch: Pitch) {
        headerView.pitch = pitch
        plotView.pitch = pitch
        accuracyView.setCentOffset(pitch.cents, animated: true)
    }

    func tuner(_ tuner: Tuner, didSampleSoundWithAmplitude amplitude: Double) {
        plotView.amplitude = amplitude
    }

}

extension TunerViewController: SettingsDefaultsObserving {

    func reloadSettingsFromDefaults() {
        let settings = Defaults[.settings].tuner

        headerView.accidental = settings.accidental

        let range: ClosedRange<Int>
        switch settings.inTuneLevel {
        case .narrow: range = -2...2
        case .medium: range = -5...5
        case .wide: range = -10...10
        }
        plotView.inTuneCentRange = range
        accuracyView.inTuneCentRange = range

        switch settings.activationVolumeLevel {
        case .quiet: tuner.activationAmplitude = 0.05
        case .medium: tuner.activationAmplitude = 0.2
        case .loud: tuner.activationAmplitude = 0.35
        }
    }

}
