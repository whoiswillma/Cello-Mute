//
//  BPMMonitor.swift
//  Cello Mute
//
//  Created by William Ma on 11/17/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import Foundation

protocol BPMMonitorDelegate: AnyObject {

    func bpmMonitorDidStartDetectingBPM(_ bpmMonitor: BPMMonitor)
    func bpmMonitor(_ bpmMonitor: BPMMonitor, didDetectBPM bpm: Int)
    func bpmMonitorDidStopDetectingBPM(_ bpmMonitor: BPMMonitor)

}

class BPMMonitor {

    let tapHistory = CircularBuffer<Date>(absoluteSize: 5)

    var timeout: TimeInterval = 2

    var detectedBpm: Int {
        let interval = tapHistory.averageInterval
        if interval > 0 {
            return Int(round(60 / interval))
        } else {
            return 0
        }
    }

    private(set) var isDetectingBpm: Bool = false

    weak var delegate: BPMMonitorDelegate?

    private var timeoutTimer: Timer?

    func tap() {
        if !isDetectingBpm {
            tapHistory.clear()
            isDetectingBpm = true
            delegate?.bpmMonitorDidStartDetectingBPM(self)
        }

        tapHistory.add(Date())
        if tapHistory.isFilled {
            delegate?.bpmMonitor(self, didDetectBPM: detectedBpm)
        }

        timeoutTimer?.invalidate()
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            guard let `self` = self else {
                return
            }

            self.isDetectingBpm = false
            self.delegate?.bpmMonitorDidStopDetectingBPM(self)
        }
    }

    func stopDetecting() {
        timeoutTimer?.fire()
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }

}

private extension CircularBuffer where T == Date {

    var averageInterval: TimeInterval {
        var totalInterval = 0.0
        var count = 0

        let dates = buffer.compactMap { $0 }

        for (i, start) in dates.enumerated() {
            let end = dates[(i + 1) % buffer.count]
            let interval = end.timeIntervalSince(start)
            if interval > 0 {
                totalInterval += interval
                count += 1
            }
        }

        return count == 0 ? 0 : totalInterval / Double(count)
    }

    var latest: Date? {
        return buffer.compactMap { $0 }.max { $0.timeIntervalSince($1) < 0 }
    }

}
