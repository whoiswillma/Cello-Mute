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

    private(set) var tuner: Tuner!
    private(set) var metronome: Metronome!
    private(set) var generator: Generator!

    private var started: Bool

    private init() {
        print(AKSettings.sampleRate, AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate)
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        print(AKSettings.sampleRate, AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate)

        AKSettings.audioInputEnabled = true

        tuner = Tuner()
        metronome = Metronome()
        generator = Generator()

        // audiokit

        let mixer = AKMixer(tuner.output, metronome.output, generator.output)
        AudioKit.output = mixer

        started = false
    }

    func start() throws {
        guard !started else {
            return
        }

        try AKSettings.setSession(category: .playAndRecord)
        //        try AKSettings.setSession(category: .playAndRecord, with: .mixWithOthers)
        AKSettings.defaultToSpeaker = true

        try AudioKit.start()

        started = true
    }

}
