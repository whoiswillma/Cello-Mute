//
//  TenorEngine.swift
//  Cello Mute
//
//  Created by William Ma on 11/17/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import AudioKit
import Foundation

final class TenorEngine {

    static let shared = TenorEngine()

    let tuner: Tuner
    let metronome: Metronome
    let generator: Generator

    private var started: Bool

    private init() {
        tuner = Tuner()
        metronome = Metronome()
        generator = Generator()

        started = false
    }

    func start() throws {
        guard !started else {
            return
        }

        // audiokit

        let mixer = AKMixer(tuner.output, metronome.output, generator.output)
        AudioKit.output = mixer

        try AKSettings.setSession(category: .playAndRecord)
        AKSettings.defaultToSpeaker = true

        try AudioKit.start()

        started = true
    }

}
