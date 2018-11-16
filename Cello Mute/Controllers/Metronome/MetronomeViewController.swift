//
//  MetronomeViewController.swift
//  Cello Mute
//
//  Created by William Ma on 11/17/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import SwiftNotificationCenter
import SwiftyUserDefaults

class MetronomeViewController: UIViewController {

    private static let parametersKey = DefaultsKey<Parameters>(
        "com.williamma.Cello-Mute.MetronomeViewController.parametersKey",
        defaultValue: Parameters())

    struct Parameters: Codable, DefaultsSerializable {

        var bpm: Int
        var rhythm: Rhythm

        init(bpm: Int = 120, rhythm: Rhythm = .commonTime) {
            self.bpm = bpm
            self.rhythm = rhythm
        }

    }

    private enum SegueIdentifier: String {

        case embedRhythmViewController

    }

    static let bpmRange = 20...200

    private weak var rhythmViewController: RhythmViewController!

    @IBOutlet private weak var pickerView: BPMPickerView!

    @IBOutlet private weak var tapBeatButton: UIButton!
    @IBOutlet private weak var playPauseButton: UIButton!

    private let bpmRange = MetronomeViewController.bpmRange

    private var metronome: Metronome!
    private let bpmMonitor = BPMMonitor()
    private var startMetronomeAfterDetectionFinishes = false

    private var bpm: Int = 120 {
        didSet {
            bpm = MetronomeViewController.bpmRange.clamp(bpm)
        }
    }
    private var rhythm: Rhythm = .commonTime

    override func viewDidLoad() {
        super.viewDidLoad()

        metronome = TenorEngine.shared.metronome
        metronome.delegate = self

        bpmMonitor.delegate = self

        rhythmViewController.delegate = self

        pickerView.delegate = self

        Broadcaster.register(AppStateObserver.self, observer: self)

        reloadSettingsFromDefaults()
        Broadcaster.register(SettingsDefaultsObserving.self, observer: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadMetronomeParametersFromDefaults()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Warnings.shared.showLowVolumeWarningIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if metronome.isStarted {
            metronome.stop()
        }

        saveMetronomeParametersToDefaults()
    }

    @IBAction private func playPauseButtonPressed() {
        if metronome.isStarted {
            metronome.stop()
        } else {
            if bpmMonitor.isDetectingBpm {
                bpmMonitor.stopDetecting()
            }

            if !metronome.isStarted {
                metronome.start(bpm: bpm, rhythm: rhythm)
            }
        }
    }

    @IBAction func tapBeatButtonPressed() {
        bpmMonitor.tap()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let rawValue = segue.identifier, let identifier = SegueIdentifier(rawValue: rawValue) else {
            print("Segue with identifier \(String(describing: segue.identifier)) was unexpectedly performed")
            return
        }

        switch identifier {
        case .embedRhythmViewController:
            rhythmViewController = (segue.destination as! RhythmViewController)
        }
    }

    private func loadMetronomeParametersFromDefaults() {
        let parameters = Defaults[MetronomeViewController.parametersKey]
        bpm = parameters.bpm
        pickerView.selectBpm(closestTo: bpm, animated: false)

        rhythm = parameters.rhythm
        rhythmViewController.rhythm = rhythm

        print("Loaded metronome parameters from defaults")
    }

    private func saveMetronomeParametersToDefaults() {
        let parameters = Parameters(bpm: bpm, rhythm: rhythm)
        Defaults[MetronomeViewController.parametersKey] = parameters

        print("Saved metronome parameters to defaults")
    }

}

extension MetronomeViewController: MetronomeDelegate {

    func metronomeDidStart(_ metronome: Metronome) {
        playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
    }

    func metronome(_ metronome: Metronome, didTickBeat beat: Int, subdivision: Int) {
        rhythmViewController.highlightedBeat = beat
    }

    func metronomeDidStop(_ metronome: Metronome) {
        playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
    }

    func metronomeDidReset(_ metronome: Metronome) {
        rhythmViewController.highlightedBeat = nil
    }

}

extension MetronomeViewController: BPMMonitorDelegate {

    func bpmMonitorDidStartDetectingBPM(_ bpmMonitor: BPMMonitor) {
        print("Started detecting BPM")
        tapBeatButton.setTitle("Keep Tapping...", for: .normal)

        startMetronomeAfterDetectionFinishes = metronome.isStarted
        metronome.stop()
    }

    func bpmMonitor(_ bpmMonitor: BPMMonitor, didDetectBPM newBpm: Int) {
        bpm = newBpm

        pickerView.selectBpm(closestTo: newBpm, animated: true)
    }

    func bpmMonitorDidStopDetectingBPM(_ bpmMonitor: BPMMonitor) {
        print("Stopped detecting BPM")
        tapBeatButton.setTitle("Tap The Beat", for: .normal)

        if startMetronomeAfterDetectionFinishes {
            metronome.start(bpm: bpm, rhythm: rhythm)
        }
    }

}

extension MetronomeViewController: BPMPickerViewDelegate {

    func bpmPickerView(_ bpmPickerView: BPMPickerView, didSelectBPM newBpm: Int) {
        if metronome.isStarted {
            metronome.stop()
            metronome.start(bpm: bpm, rhythm: rhythm)
        }
    }

}

extension MetronomeViewController: RhythmViewControllerDelegate {

    func rhythmViewController(_ rhythmViewController: RhythmViewController, rhythmDidChange newRhythm: Rhythm) {
        rhythm = newRhythm

        if metronome.isStarted {
            metronome.stop()
        }

        metronome.reset()
    }

}

extension MetronomeViewController: AppStateObserver {

    func applicationWillResignActive(_ application: UIApplication) {
        saveMetronomeParametersToDefaults()
    }

}

extension MetronomeViewController: SettingsDefaultsObserving {

    func reloadSettingsFromDefaults() {
        let settings = Defaults[.settings].metronome
        pickerView.allowsPreciseSelection = settings.preciseSelection
    }

}
