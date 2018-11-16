//
//  Settings.swift
//  Cello Mute
//
//  Created by William Ma on 1/12/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

/**
 The various settings the SettingsTableViewController manages. Other view
 controllers can store user defaults, but settings are specific to the settings
 displayed by the SettingsTableViewController.
 */
struct Settings: Codable, DefaultsSerializable {

    struct TunerSettings: Codable {

        enum InTuneLevel: String, Codable {

            case narrow
            case medium
            case wide

        }

        enum ActivationVolumeLevel: String, Codable {

            case quiet
            case medium
            case loud

        }

        var accidental: Note.PitchChangingAccidental
        var inTuneLevel: InTuneLevel
        var activationVolumeLevel: ActivationVolumeLevel

        init() {
            self.accidental = .sharp
            self.inTuneLevel = .medium
            self.activationVolumeLevel = .medium
        }

    }

    struct MetronomeSettings: Codable {

        var preciseSelection: Bool

        init() {
            self.preciseSelection = false
        }

    }

    struct GeneratorSettings: Codable {

        var accidental: Note.PitchChangingAccidental

        init() {
            self.accidental = .sharp
        }

    }

    var tuner: TunerSettings
    var metronome: MetronomeSettings
    var generator: GeneratorSettings

    init() {
        tuner = TunerSettings()
        metronome = MetronomeSettings()
        generator = GeneratorSettings()
    }

}
