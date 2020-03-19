//
//  Generator.swift
//  Cello Mute
//
//  Created by William Ma on 12/29/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import AudioKit
import Foundation

final class Generator {

    let output: AKNode

    var isPlaying: Bool {
        return oscillator.amplitude == 1
    }

    private let oscillator: AKOscillator

    private var deactivationTimer: Timer?

    required init() {
        oscillator = AKOscillator()
        oscillator.amplitude = 0
        oscillator.rampDuration = 0.05

        output = oscillator
    }

    func activate() {
        deactivationTimer?.invalidate()

        oscillator.start()
    }

    func play(pitch: Pitch) {
        oscillator.frequency = pitch.frequency
        oscillator.amplitude = 1
    }

    func silence() {
        oscillator.amplitude = 0
    }

    func deactivate() {
        oscillator.amplitude = 0

        deactivationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { [weak self] _ in
            self?.oscillator.stop()
        }
    }

}
