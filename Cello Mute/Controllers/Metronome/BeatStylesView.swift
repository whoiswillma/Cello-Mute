//
//  BeatStylesView.swift
//  Cello Mute
//
//  Created by William Ma on 12/25/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit

protocol BeatStylesViewDelegate: AnyObject {

    func beatStylesView(_ beatStylesView: BeatStylesView, beatStylesDidChange beatStyles: [Rhythm.BeatStyle])

}

class BeatStylesView: UIView {

    private let beatCircles = (0..<8).map { _ in UIButton(type: .custom) }

    var beatStyles: [Rhythm.BeatStyle] = Rhythm.commonTime.beatStyles {
        didSet {
            layoutBeatCircles()
            updateBeatCircleVisual()
        }
    }

    var highlightedBeat: Int? {
        willSet {
            if let beat = highlightedBeat {
                beatCircles[beat].backgroundColor = nil
            }
        }
        didSet {
            if let beat = highlightedBeat, 0 <= beat, beat <= 7 {
                beatCircles[beat].backgroundColor = .tint
            }
        }
    }

    // The ratio of a beat's width and height to the lesser of the width and height
    private let beatToMinorDimensionRatio: CGFloat = 1 / 5

    weak var delegate: BeatStylesViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        for circle in beatCircles {
            circle.layer.borderColor = UIColor.black.cgColor
            circle.addTarget(self, action: #selector(beatCirclePressed(_:)), for: .touchUpInside)
            addSubview(circle)
        }

        updateBeatCircleVisual()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutBeatCircles()
    }

    private func layoutBeatCircles() {
        let beats = beatStyles.count

        let beatSize = beatToMinorDimensionRatio * min(bounds.width, bounds.height)
        for circle in beatCircles {
            circle.bounds = CGRect(x: 0, y: 0, width: beatSize, height: beatSize)
            circle.layer.cornerRadius = beatSize / 2
        }

        for (i, circle) in beatCircles.enumerated() {
            circle.isHidden = false

            if beats <= 4 {
                circle.center = CGPoint(x: CGFloat(i + 1) * bounds.width / CGFloat(beats + 1), y: bounds.midY)
            } else {
                if i < 4 {
                    circle.center = CGPoint(x: CGFloat(i + 1) * bounds.width / CGFloat(5), y: bounds.height / 3)
                } else {
                    circle.center = CGPoint(x: CGFloat((i - 4) + 1) * bounds.width / CGFloat((beats - 4) + 1), y: 2 * bounds.height / 3)
                }
            }
        }

        for circle in beatCircles[beats...] {
            circle.isHidden = true
        }
    }

    private func updateBeatCircleVisual() {
        for (i, style) in beatStyles.enumerated() {
            let circle = beatCircles[i]

            switch style {
            case .normal:
                circle.layer.borderWidth = 6
            case .emphasised:
                circle.layer.borderWidth = max(circle.layer.bounds.width, circle.layer.bounds.height) / 2
            case .silent:
                circle.layer.borderWidth = 2
            }
        }
    }

    @objc private func beatCirclePressed(_ sender: UIButton) {
        guard let index = beatCircles.firstIndex(of: sender) else {
            print("\(#selector(beatCirclePressed(_:))) called with an invalid sender")
            return
        }

        switch beatStyles[index] {
        case .normal: beatStyles[index] = .emphasised
        case .emphasised: beatStyles[index] = .silent
        case .silent: beatStyles[index] = .normal
        }

        delegate?.beatStylesView(self, beatStylesDidChange: beatStyles)
    }

}
