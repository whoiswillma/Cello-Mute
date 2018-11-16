//
//  Warnings.swift
//  Cello Mute
//
//  Created by William Ma on 2/2/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import NotificationBannerSwift
import AVKit
import Foundation

private class BannerColor: BannerColorsProtocol {

    func color(for style: BannerStyle) -> UIColor {
        return .tint
    }

}

class Warnings {

    static let shared = Warnings()

    private var lastMicrophoneAccessWarning: Date?
    private var shouldShowMicrophoneAccessWarning: Bool {
        if let last = lastMicrophoneAccessWarning {
            return abs(last.timeIntervalSinceNow) >= 60 * 15
        } else {
            return true
        }
    }

    private var lastLowVolumeWarning: Date?
    private let lowVolumeCutoff: Float = 2 / 16
    private var volumeObservation: NSKeyValueObservation?
    private var shouldShowLowVolumeWarning: Bool {
        if let last = lastLowVolumeWarning {
            return abs(last.timeIntervalSinceNow) >= 60 * 15
        } else {
            return true
        }
    }

    func showMicrophoneAccessWarningIfNeeded() {
        guard shouldShowMicrophoneAccessWarning else {
            return
        }

        switch AVAudioSession.sharedInstance().recordPermission {
        case .denied:
            let banner = NotificationBanner(title: "Microphone Permission Disabled",
                                            subtitle: "Tap This Banner To Open Settings",
                                            style: .info,
                                            colors: BannerColor())
            banner.haptic = .none
            banner.onTap = {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                UIApplication.shared.open(settingsUrl) { _ in
                    banner.dismiss()
                }
            }

            banner.show()
        default:
            break
        }

        lastMicrophoneAccessWarning = Date()
    }

    func showLowVolumeWarningIfNeeded() {
        guard shouldShowLowVolumeWarning else {
            return
        }

        let banner = StatusBarNotificationBanner(title: "Device Volume Low", style: .warning, colors: BannerColor())

        volumeObservation = AVAudioSession.sharedInstance().observe(\.outputVolume) { [weak self] session, change in
            guard let `self` = self else {
                return
            }

            if AVAudioSession.sharedInstance().outputVolume >= self.lowVolumeCutoff {
                banner.dismiss()
                self.volumeObservation?.invalidate()
            }
        }

        if AVAudioSession.sharedInstance().outputVolume < lowVolumeCutoff {
            banner.show()
        }

        lastLowVolumeWarning = Date()
    }

}
