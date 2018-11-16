//
//  TunerInTuneLevelTableViewCell.swift
//  Cello Mute
//
//  Created by William Ma on 1/12/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit

class TunerInTuneLevelTableViewCell: UITableViewCell {

    @IBOutlet private weak var segmentedControl: UISegmentedControl!

    var inTuneLevel: Settings.TunerSettings.InTuneLevel {
        get {
            switch segmentedControl.selectedSegmentIndex {
            case 0: return .narrow
            case 1: return .medium
            case 2: return .wide
            default: return .medium
            }
        }
        set {
            switch newValue {
            case .narrow: segmentedControl.selectedSegmentIndex = 0
            case .medium: segmentedControl.selectedSegmentIndex = 1
            case .wide: segmentedControl.selectedSegmentIndex = 2
            }
        }
    }

    var inTuneLevelDidChange: (() -> Void)?

    @IBAction private func segmentedControlValueChanged() {
        inTuneLevelDidChange?()
    }

}
