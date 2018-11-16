//
//  UIColor.swift
//  Cello Mute
//
//  Created by William Ma on 11/16/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(between first: UIColor, _ second: UIColor, factor: CGFloat) {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0
        first.getRed(&r1, green: &g1, blue: &b1, alpha: nil)

        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0
        second.getRed(&r2, green: &g2, blue: &b2, alpha: nil)

        let r = r1 + (r2 - r1) * factor
        let g = g1 + (g2 - g1) * factor
        let b = b1 + (b2 - b1) * factor
        self.init(red: r, green: g, blue: b, alpha: 1)
    }

    func withSaturation(_ saturation: CGFloat) -> UIColor {
        var hue: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    func withBrightness(_ brightness: CGFloat) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    static let tint = UIColor(named: "Tint")!

}
