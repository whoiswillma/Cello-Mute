//
//  RoundedRectButton.swift
//  Cello Mute
//
//  Created by William Ma on 12/29/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit

class RoundedRectButton: UIButton {

    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue

            updateAppearance()
        }
    }

    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue

            updateAppearance()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderWidth = 4 / 3
        layer.cornerRadius = 8

        updateAppearance()
    }

    private func updateAppearance() {
        if isHighlighted {
            layer.borderColor = tintColor.withAlphaComponent(2 / 3).cgColor
        } else {
            layer.borderColor = tintColor.cgColor
        }

        if isSelected {
            backgroundColor = tintColor.withAlphaComponent(1 / 3)
        } else {
            backgroundColor = nil
        }
    }

}
