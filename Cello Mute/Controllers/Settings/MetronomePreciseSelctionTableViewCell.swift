//
//  MetronomePreciseSelctionTableViewCell.swift
//  Cello Mute
//
//  Created by William Ma on 1/1/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit

class MetronomePreciseSelctionTableViewCell: UITableViewCell {

    @IBOutlet private weak var preciseSelectionSwitch: UISwitch!

    var enabled: Bool {
        get {
            return preciseSelectionSwitch.isOn
        }
        set {
            preciseSelectionSwitch.isOn = newValue
        }
    }

    var enabledValueChanged: (() -> Void)?

    @IBAction func switchValueChanged() {
        enabledValueChanged?()
    }

}
