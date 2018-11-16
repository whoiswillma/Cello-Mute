//
//  TunerActivationVolumeLevelTableViewCell.swift
//  Cello Mute
//
//  Created by William Ma on 1/13/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit

class TunerActivationVolumeLevelTableViewCell: UITableViewCell {

    @IBOutlet private weak var segmentedControl: UISegmentedControl!

    var activationVolumeLevel: Settings.TunerSettings.ActivationVolumeLevel {
        get {
            switch segmentedControl.selectedSegmentIndex {
            case 0: return .quiet
            case 1: return .medium
            case 2: return .loud
            default: return .medium
            }
        }
        set {
            switch newValue {
            case .quiet: segmentedControl.selectedSegmentIndex = 0
            case .medium: segmentedControl.selectedSegmentIndex = 1
            case .loud: segmentedControl.selectedSegmentIndex = 2
            }
        }
    }

    var activationVolumeLevelDidChange: (() -> Void)?

    @IBAction private func segmentedControlValueChanged() {
        activationVolumeLevelDidChange?()
    }

}
