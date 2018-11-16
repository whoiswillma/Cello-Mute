//
//  FlatsShapsTableViewCell.swift
//  Cello Mute
//
//  Created by William Ma on 1/1/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit

class FlatsSharpsTableViewCell: UITableViewCell {

    @IBOutlet private weak var segmentedControl: UISegmentedControl!

    var accidental: Note.PitchChangingAccidental {
        get {
            return segmentedControl.selectedSegmentIndex == 0 ? .flat : .sharp
        }
        set {
            segmentedControl.selectedSegmentIndex = newValue == .flat ? 0 : 1
        }
    }

    var accidentalDidChange: (() -> Void)?

    @IBAction private func segmentedControlValueChanged() {
        accidentalDidChange?()
    }

}
