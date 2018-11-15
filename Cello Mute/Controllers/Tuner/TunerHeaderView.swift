//
//  TunerHeaderView.swift
//  Cello Mute
//
//  Created by William Ma on 11/14/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit

class TunerHeaderView: UIView {

    static func loadFromNib() -> TunerHeaderView {
        return UINib(nibName: "TunerHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! TunerHeaderView
    }

    enum TrackingStatus {

        case notTracking
        case inactivelyTracking
        case activelyTracking

    }

    @IBOutlet private weak var centsLabel: UILabel!
    @IBOutlet private weak var frequencyLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var playLouderLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!

    var semitoneAdjustment: Pitch.SemitoneAdjustmentMethod = .sharps

    var pitch: Pitch? {
        didSet {
            let displayedPitch: Pitch
            if let pitch = pitch {
                displayedPitch = pitch
            } else {
                displayedPitch = Pitch(frequency: 440)!
            }

            noteLabel.attributedText = displayedPitch.closestNote(using: semitoneAdjustment).normalizedDescription()
            centsLabel.text = "cents: \(displayedPitch.cents)"
            frequencyLabel.text = "frequency: \(Int(round(displayedPitch.frequency)))"
        }
    }

    var trackingStatus: TrackingStatus = .notTracking {
        didSet {
            func setTextColor(_ textColor: UIColor, of label: UILabel) {
                UIView.transition(with: label, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    label.textColor = textColor
                }, completion: nil)
            }

            switch trackingStatus {
            case .activelyTracking:
                UIView.animate(withDuration: 0.5) {
                    self.backgroundColor = self.tintColor.withAlphaComponent(0.25)
                    self.playLouderLabel.alpha = 0
                }
                setTextColor(.black, of: centsLabel)
                setTextColor(.black, of: noteLabel)
                setTextColor(.black, of: frequencyLabel)
            case .inactivelyTracking:
                UIView.animate(withDuration: 0.5) {
                    self.backgroundColor = nil
                    self.playLouderLabel.alpha = 1
                }
                setTextColor(tintColor, of: centsLabel)
                setTextColor(tintColor, of: noteLabel)
                setTextColor(tintColor, of: frequencyLabel)
            case .notTracking:
                UIView.animate(withDuration: 0.5) {
                    self.backgroundColor = nil
                    self.playLouderLabel.alpha = 0
                }
                setTextColor(.black, of: centsLabel)
                setTextColor(.black, of: noteLabel)
                setTextColor(.black, of: frequencyLabel)
            }
        }
    }

    override func awakeFromNib() {
        pitch = nil
        trackingStatus = .notTracking
    }

}

private extension Note {

    static let font = UIFont.systemFont(ofSize: 100, weight: .bold)
    static let octaveFont = UIFont.systemFont(ofSize: 50, weight: .bold)

    func normalizedDescription() -> NSAttributedString {
        let text = "\(name.text)\(octave)"
        let attributedText = NSMutableAttributedString(string: text, attributes: [.font: Note.font])
        attributedText.setAttributes(
            [.font: Note.octaveFont, .baselineOffset: -25],
            range: NSRange(2..<attributedText.length))
        return attributedText
    }

}
