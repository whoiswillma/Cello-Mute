//
//  Tuner.swift
//  Cello Mute
//
//  Created by William Ma on 11/14/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import AudioKit
import Foundation

protocol TunerDelegate: class {

    func tunerDidStartTracking(_ tuner: Tuner)
    func tunerDidStopTracking(_ tuner: Tuner)

    func tunerDidBeginInactivelyTracking(_ tuner: Tuner)
    func tunerDidEndInactivelyTracking(_ tuner: Tuner)

    func tunerDidBeginActivelyTracking(_ tuner: Tuner)
    func tunerDidEndActivelyTracking(_ tuner: Tuner)

    func tuner(_ tuner: Tuner, didSample pitch: Pitch)

}

class Tuner {

    private let tracker = AKMicrophoneTracker()

    var inactivePollPeriod: TimeInterval = 0.25
    var activePollPeriod: TimeInterval = 0.1

    var activationAmplitude: Double = 0.15
    let amplitudeHistory = CircularBuffer<Double>(size: 10)
    let absoluteCentHistory = CircularBuffer<Int>(size: 10)

    weak var delegate: TunerDelegate?

    private var previousSampleAmplitude: Double = 0
    private var isActivelyTracking: Bool = false
    private var timer: Timer?

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

        if amplitudeHistory.average >= activationAmplitude, !isActivelyTracking {
            timer?.invalidate()
            isActivelyTracking = true
            delegate?.tunerDidEndInactivelyTracking(self)

            absoluteCentHistory.removeAll()
            timer = Timer.scheduledTimer(withTimeInterval: activePollPeriod, repeats: true) { [weak self] _ in
                guard let `self` = self else {
                    return
                }

                if let pitch = Pitch(frequency: self.tracker.frequency) {
                    self.absoluteCentHistory.add(pitch.absoluteCents)
                }

                if let pitch = Pitch(absoluteCents: self.absoluteCentHistory.average),
                    self.absoluteCentHistory.count == self.absoluteCentHistory.buffer.count {
                    self.delegate?.tuner(self, didSample: pitch)
                }

                self.sample()
            }
            delegate?.tunerDidBeginActivelyTracking(self)
        } else if amplitudeHistory.average < activationAmplitude, isActivelyTracking {
            timer?.invalidate()
            isActivelyTracking = false
            delegate?.tunerDidEndActivelyTracking(self)

            timer = Timer.scheduledTimer(withTimeInterval: activePollPeriod, repeats: true) { [weak self] _ in
                self?.sample()
            }
            delegate?.tunerDidBeginInactivelyTracking(self)
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

}

private extension CircularBuffer where T == Double {

    var average: T {
        var total: T = 0
        var count: T = 0
        for value in buffer {
            if let value = value {
                total += value
                count += 1
            }
        }
        return count == 0 ? 0 : total / count
    }

}

private extension CircularBuffer where T == Int {

    var average: T {
        var total: T = 0
        var count: T = 0
        for value in buffer {
            if let value = value {
                total += value
                count += 1
            }
        }
        return count == 0 ? 0 : total / count
    }

}
