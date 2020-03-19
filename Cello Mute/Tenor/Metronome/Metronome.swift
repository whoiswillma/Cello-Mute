//
//  Metronome.swift
//  Cello Mute
//
//  Created by William Ma on 11/17/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import AudioKit
import Foundation

protocol MetronomeDelegate: AnyObject {

    func metronomeDidStart(_ metronome: Metronome)
    func metronome(_ metronome: Metronome, didTickBeat beat: Int, subdivision: Int)
    func metronomeDidStop(_ metronome: Metronome)
    func metronomeDidReset(_ metronome: Metronome)

}

final class Metronome {

    let output: AKNode

    var isStarted: Bool {
        get {
            if let timer = timer, timer.isValid {
                return true
            } else {
                return false
            }
        }
    }

    private var currentTick: Int?
    private var playingBpm: Int?
    private var playingRhythm: Rhythm?

    private let normalNoise: AKPlayer?
    private let emphasisedNoise: AKPlayer?
    private let subdivisionNoises: [AKPlayer?]

    private var timer: Timer?

    weak var delegate: MetronomeDelegate?

    required init() {
        normalNoise = AKPlayer(url: Resources.WoodBlock.Medium.normal)
        emphasisedNoise = AKPlayer(url: Resources.WoodBlock.Medium.emphasized)

        // have multiple subdivision noises for possible overlap
        subdivisionNoises = (1...3).map { _ in AKPlayer(url: Resources.WoodBlock.Medium.subdivision) }

        output = AKMixer(([normalNoise, emphasisedNoise] + subdivisionNoises).compactMap { $0 })
    }

    func start(bpm: Int, rhythm: Rhythm) {
        guard !isStarted else {
            return
        }

        playingBpm = bpm
        playingRhythm = rhythm

        let interval = 60 / Double(bpm) / rhythm.subdivisionLevel
        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer

        // need to notify the delegate before the first tick is played
        delegate?.metronomeDidStart(self)

        tick()
    }

    private func tick() {
        guard let rhythm = playingRhythm else {
            print("A tick was performed without a rhythm ")
            return
        }

        var tick: Int
        if let currentTick = currentTick {
            tick = currentTick
        } else {
            tick = 0
        }

        let beat = tick / rhythm.subdivisionLevel % rhythm.beatStyles.count
        let subdivision = tick % rhythm.subdivisionLevel - 1

        if tick % rhythm.subdivisionLevel == 0 {
            switch rhythm.beatStyles[beat] {
            case .normal:
                normalNoise?.play()
            case .emphasised:
                emphasisedNoise?.play()
            case .silent:
                break
            }
        } else {
            subdivisionNoises[subdivision]?.play()
        }

        tick += 1
        currentTick = tick

        delegate?.metronome(self, didTickBeat: beat, subdivision: subdivision)
    }

    func stop() {
        guard isStarted else {
            return
        }

        timer?.invalidate()
        timer = nil

        playingRhythm = nil

        delegate?.metronomeDidStop(self)
    }

    func reset() {
        guard !isStarted else {
            return
        }

        currentTick = nil

        delegate?.metronomeDidReset(self)
    }

}
