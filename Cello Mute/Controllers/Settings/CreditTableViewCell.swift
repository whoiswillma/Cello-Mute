//
//  CreditTableViewCell.swift
//  Cello Mute
//
//  Created by William Ma on 1/1/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit

class CreditTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!

    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

}
