//
//  SegmentedSlider.swift
//  Cello Mute
//
//  Created by William Ma on 12/23/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit

protocol SegmentedSliderDelegate: AnyObject {

    func segmentedSlider(_ segmentedSlider: SegmentedSlider, segmentDidChange segment: Int)

}

class SegmentedSlider: UISlider {

    var numberOfSegments: Int = 8 {
        didSet {
            updateTicks()
            maximumValue = Float(numberOfSegments)
        }
    }

    private var ticks: [CALayer] = []
    private let tickSize = CGSize(width: 2, height: 16)

    weak var delegate: SegmentedSliderDelegate?

    var segment: Int {
        get {
            return (0...(numberOfSegments - 1)).clamp(Int(round(value - 0.5)))
        }
        set {
            value = Float(newValue) + 0.5
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }

    private func initialize() {
        isContinuous = true

        minimumValue = 0
        maximumValue = Float(numberOfSegments)

        minimumTrackTintColor = .tint
        maximumTrackTintColor = .lightGray

        addTarget(self, action: #selector(valueChanged), for: .valueChanged)

        updateTicks()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateTicks()
    }

    @objc private func valueChanged() {
        let newSegment = segment
        segment = newSegment

        updateTickColor()

        delegate?.segmentedSlider(self, segmentDidChange: newSegment)
    }

    private func updateTicks() {
        while ticks.count < numberOfSegments {
            let tick = CALayer()
            ticks.append(tick)
            layer.addSublayer(tick)
        }

        let widthBetweenTicks = bounds.width / CGFloat(numberOfSegments + 1)
        for i in 0..<numberOfSegments {
            let tick = ticks[i]

            tick.isHidden = false
            tick.frame = CGRect(origin: CGPoint(x: CGFloat(i + 1) * widthBetweenTicks, y: bounds.midY - tickSize.height / 2),
                                size: tickSize)
        }

        for tick in ticks[numberOfSegments...] {
            tick.isHidden = true
        }

        updateTickColor()
    }

    private func updateTickColor() {
        let roundedValue = (0...(numberOfSegments - 1)).clamp(Int(round(value - 0.5)))

        for tick in ticks[..<roundedValue] {
            tick.backgroundColor = minimumTrackTintColor?.cgColor
        }
        for tick in ticks[roundedValue...] {
            tick.backgroundColor = maximumTrackTintColor?.cgColor
        }
    }

}
