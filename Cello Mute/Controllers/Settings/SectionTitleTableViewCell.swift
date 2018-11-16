//
//  SectionTitleTableViewCell.swift
//  Cello Mute
//
//  Created by William Ma on 1/13/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit

class SectionTitleTableViewCell: UITableViewCell {

    @IBOutlet private weak var label: UILabel!

    var title: String? {
        get { return label.text }
        set { label.text = newValue }
    }

}
