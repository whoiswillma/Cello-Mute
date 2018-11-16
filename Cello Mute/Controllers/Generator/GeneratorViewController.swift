//
//  GeneratorViewController.swift
//  Cello Mute
//
//  Created by William Ma on 12/29/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import NotificationBannerSwift
import SwiftNotificationCenter
import SwiftyUserDefaults
import UIKit

class GeneratorViewController: UIViewController {

    @IBOutlet private weak var staffNoteView: StaffNoteView!

    @IBOutlet private weak var octaveSegmentedControl: UISegmentedControl!

    @IBOutlet private weak var cButton: RoundedRectButton!
    @IBOutlet private weak var cSharpButton: RoundedRectButton!
    @IBOutlet private weak var dButton: RoundedRectButton!
    @IBOutlet private weak var dSharpButton: RoundedRectButton!
    @IBOutlet private weak var eButton: RoundedRectButton!
    @IBOutlet private weak var fButton: RoundedRectButton!
    @IBOutlet private weak var fSharpButton: RoundedRectButton!
    @IBOutlet private weak var gButton: RoundedRectButton!
    @IBOutlet private weak var gSharpButton: RoundedRectButton!
    @IBOutlet private weak var aButton: RoundedRectButton!
    @IBOutlet private weak var aSharpButton: RoundedRectButton!
    @IBOutlet private weak var bButton: RoundedRectButton!
    private var keyButtons: [RoundedRectButton]!

    @IBOutlet private weak var stopButton: RoundedRectButton!

    private var generator: Generator!

    private var selectedNoteName: Note.Name? {
        didSet {
            if let name = selectedNoteName {
                for button in keyButtons {
                    button.isSelected = false
                }

                keyButtons[name.semitone].isSelected = true
            } else {
                for button in keyButtons {
                    button.isSelected = false
                }
            }
        }
    }
    private var selectedNote: Note? {
        guard let name = selectedNoteName else {
            return nil
        }

        // the "+2" is from the segmented control in the storyboard
        return Note(name: name, octave: octaveSegmentedControl.selectedSegmentIndex + 2)
    }

    private var accidental: Note.PitchChangingAccidental = .sharp {
        didSet {
            if let noteName = selectedNoteName {
                selectedNoteName = Note.semitones(using: accidental)[noteName.semitone]
            }

            for (button, noteName) in zip(keyButtons, Note.semitones(using: accidental)) {
                button.setTitle(noteName.text, for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        generator = TenorEngine.shared.generator

        keyButtons = [
            cButton,
            cSharpButton,
            dButton,
            dSharpButton,
            eButton,
            fButton,
            fSharpButton,
            gButton,
            gSharpButton,
            aButton,
            aSharpButton,
            bButton
        ]

        reloadSettingsFromDefaults()
        Broadcaster.register(SettingsDefaultsObserving.self, observer: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        generator.activate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Warnings.shared.showLowVolumeWarningIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopGenerator()
        generator.deactivate()
    }

    @IBAction func stopButtonPressed() {
        stopGenerator()
    }

    private func stopGenerator() {
        generator.silence()
        staffNoteView.note = nil
        selectedNoteName = nil

        print("Generator stopped playing")
    }

    @IBAction private func keyButtonPressed(_ sender: RoundedRectButton) {
        guard let index = keyButtons.firstIndex(of: sender) else {
            print("\(#selector(keyButtonPressed(_:))) called but the sender was not a keyButton")
            return
        }

        selectedNoteName = Note.semitones(using: accidental)[index]

        playSelectedNote()
    }

    @IBAction private func octaveValueChanged() {
        playSelectedNote()
    }

    private func playSelectedNote() {
        guard let note = selectedNote else {
            stopGenerator()
            return
        }

        guard let pitch = note.pitch else {
            print("Could not produce pitch from note \(note)")
            return
        }

        generator.play(pitch: pitch)
        print("Started playing note \(note) at frequency \(pitch.frequency)")

        staffNoteView.note = note
    }

}

extension GeneratorViewController: SettingsDefaultsObserving {

    func reloadSettingsFromDefaults() {
        let settings = Defaults[.settings].generator
        accidental = settings.accidental
    }

}
