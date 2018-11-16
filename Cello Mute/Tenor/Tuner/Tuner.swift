//
//  Tuner.swift
//  Cello Mute
//
//  Created by William Ma on 11/14/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import AudioKit
import Foundation

protocol TunerDelegate: AnyObject {

    func tunerDidStartTracking(_ tuner: Tuner)
    func tunerDidStopTracking(_ tuner: Tuner)

    func tunerDidBeginInactivelyTracking(_ tuner: Tuner)
    func tunerDidEndInactivelyTracking(_ tuner: Tuner)

    func tunerDidBeginActivelyTracking(_ tuner: Tuner)
    func tunerDidEndActivelyTracking(_ tuner: Tuner)

    func tuner(_ tuner: Tuner, didSampleSoundAtPitch pitch: Pitch)
    func tuner(_ tuner: Tuner, didSampleSoundWithAmplitude amplitude: Double)

}

final class Tuner: TenorEngineComponent {

    typealias Amplitude = Double

    let output: AKNode

    let microphone: AKMicrophone

    weak var delegate: TunerDelegate?

    private let tracker: AKMicrophoneTracker

    var inactivePollPeriod: TimeInterval = 0.25
    var activePollPeriod: TimeInterval = 0.1

    var activationAmplitude: Amplitude = 0.15
    private let amplitudeHistory = CircularBuffer<Amplitude>(absoluteSize: 4)
    var amplitudeResistance: Int {
        get { return amplitudeHistory.absoluteSize }
        set { amplitudeHistory.absoluteSize = newValue }
    }

    private let pitchHistory = CircularBuffer<Pitch>(absoluteSize: 10)
    var pitchResistance: Int {
        get { return pitchHistory.absoluteSize }
        set { pitchHistory.absoluteSize = newValue }
    }

    private var isActivelyTracking: Bool = false
    private var timer: Timer?

    required init() {
        microphone = AKMicrophone()
        output = AKBooster(microphone, gain: 0)
        tracker = AKMicrophoneTracker()
    }

    func startTracking() {
        isActivelyTracking = false

        tracker.start()

        timer = Timer.scheduledTimer(withTimeInterval: inactivePollPeriod, repeats: true) { [weak self] _ in
            self?.sample()
        }

        delegate?.tunerDidStartTracking(self)
        delegate?.tunerDidBeginInactivelyTracking(self)
    }

    private func sample() {
        let amplitude = tracker.amplitude
        amplitudeHistory.add(amplitude)

        delegate?.tuner(self, didSampleSoundWithAmplitude: amplitudeHistory.averageAmplitude)

        if amplitudeHistory.averageAmplitude >= activationAmplitude, !isActivelyTracking {
            timer?.invalidate()
            isActivelyTracking = true
            delegate?.tunerDidEndInactivelyTracking(self)

            pitchHistory.clear()
            timer = Timer.scheduledTimer(withTimeInterval: activePollPeriod, repeats: true) { [weak self] _ in
                guard let `self` = self else {
                    return
                }

                self.activelySample()

                self.sample()
            }
            delegate?.tunerDidBeginActivelyTracking(self)
        } else if amplitudeHistory.averageAmplitude < activationAmplitude, isActivelyTracking {
            timer?.invalidate()
            isActivelyTracking = false
            delegate?.tunerDidEndActivelyTracking(self)

            timer = Timer.scheduledTimer(withTimeInterval: inactivePollPeriod, repeats: true) { [weak self] _ in
                self?.sample()
            }
            delegate?.tunerDidBeginInactivelyTracking(self)
        }
    }

    private func activelySample() {
        guard let currentPitch = Pitch(frequency: tracker.frequency) else {
            return
        }
        pitchHistory.add(currentPitch)

        if pitchHistory.isFilled, let averagePitch = pitchHistory.averagePitch {
            if semitonesBetween(averagePitch.closestNote(), currentPitch.closestNote()) > 1 {
                pitchHistory.clear()
            } else {
                delegate?.tuner(self, didSampleSoundAtPitch: averagePitch)
            }
        }
    }

    func stopTracking() {
        if timer == nil {
            return
        }

        timer?.invalidate()
        timer = nil

        tracker.stop()

        if isActivelyTracking {
            delegate?.tunerDidEndActivelyTracking(self)
        } else {
            delegate?.tunerDidEndInactivelyTracking(self)
        }
        delegate?.tunerDidStopTracking(self)
    }

    private func semitonesBetween(_ lhs: Note, _ rhs: Note) -> UInt {
        return ((12 * lhs.octave + lhs.name.semitone) - (12 * rhs.octave + rhs.name.semitone)).magnitude
    }

}

private extension CircularBuffer where T == Tuner.Amplitude {

    var averageAmplitude: T {
        var total: Tuner.Amplitude = 0
        var count: Int = 0
        for value in buffer {
            if let value = value {
                total += value
                count += 1
            }
        }
        return count == 0 ? 0 : total / count
    }

}

private extension CircularBuffer where T == Pitch {

    var averagePitch: T? {
        var total: Int = 0
        var count: Int = 0
        for value in buffer {
            if let value = value {
                total += value.absoluteCents
                count += 1
            }
        }
        return count == 0 ? nil : Pitch(absoluteCents: total / count)
    }

}
