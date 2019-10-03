//
//  TunerPlotView.swift
//  Cello Mute
//
//  Created by William Ma on 11/16/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class TunerPlotView: UIView {

    private var outputPlot: AKNodeOutputPlot!

    private var inactiveColor: UIColor = .black
    private var inactiveAlphaRange: ClosedRange<CGFloat> = 0.25...1

    var inTuneCentRange = -5...5

    var inputNode: AKNode? {
        didSet {
            outputPlot?.removeFromSuperview()

            guard let inputNode = inputNode else {
                return
            }

            let plot = AKNodeOutputPlot(inputNode)
            plot.clipsToBounds = true
            plot.plotType = .rolling
            plot.shouldFill = true
            plot.backgroundColor = nil
            plot.shouldMirror = true
            plot.color = inactiveColor.withAlphaComponent(inactiveAlphaRange.lowerBound)

            addSubview(plot)
            plot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                plot.topAnchor.constraint(equalTo: topAnchor),
                plot.leftAnchor.constraint(equalTo: leftAnchor),
                plot.rightAnchor.constraint(equalTo: rightAnchor),
                plot.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            outputPlot = plot
        }
    }

    var pitch: Pitch? {
        didSet {
            updateOutputPlotColor(animated: true)
        }
    }
    var amplitude: Double? {
        didSet {
            updateOutputPlotColor(animated: true)
        }
    }

    private func updateOutputPlotColor(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.35) {
                self.updateOutputPlotColor(animated: false)
            }
        } else {
            if let pitch = pitch, inTuneCentRange.contains(pitch.cents) {
                self.outputPlot.color = self.tintColor.withAlphaComponent(0.5)
            } else if let amplitude = amplitude {
                let upper = inactiveAlphaRange.upperBound
                let lower = inactiveAlphaRange.lowerBound
                let adjustedAmplitude = CGFloat(amplitude) * (upper - lower) + lower
                outputPlot.color = inactiveColor.withAlphaComponent(adjustedAmplitude)
            } else {
                outputPlot.color = inactiveColor.withAlphaComponent(0.33)
            }
        }
    }

}
