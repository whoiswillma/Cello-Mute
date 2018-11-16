//
//  TunerAccuracyView.swift
//  Cello Mute
//
//  Created by William Ma on 11/15/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit

class TunerAccuracyView: UIView {

    @IBOutlet private var accuracyView: UIView!
    private var gradient: CAGradientLayer!
    private var exactPitchView: UIView!

    var inTuneCentRange = -5...5

    @IBOutlet private var tooLowLabel: UILabel!
    @IBOutlet private var inTuneLabel: UILabel!
    @IBOutlet private var tooHighLabel: UILabel!

    private(set) var centOffset: Int?

    override func awakeFromNib() {
        let tooLowColor = UIColor(named: "Start")!.withAlphaComponent(0.25).cgColor
        let tooHighColor = UIColor(named: "End")!.withAlphaComponent(0.25).cgColor
        gradient = CAGradientLayer()
        gradient.colors = [tooLowColor, tooHighColor]
        gradient.cornerRadius = 16
        gradient.borderWidth = 2
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        accuracyView.layer.addSublayer(gradient)

        exactPitchView = UIView()
        exactPitchView.backgroundColor = nil
        exactPitchView.layer.cornerRadius = 8
        exactPitchView.layer.borderWidth = 2
        accuracyView.addSubview(exactPitchView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = accuracyView.bounds

        exactPitchView.bounds.size = CGSize(width: accuracyView.bounds.height / 2.5, height:  accuracyView.bounds.height)
        exactPitchView.center.y = accuracyView.bounds.midY
        updateExactPitchView()
    }

    func setCentOffset(_ centOffset: Int?, animated: Bool) {
        self.centOffset = centOffset

        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveLinear, animations: {
                self.updateExactPitchView()
                self.updateOutOfTuneLabels()
            }, completion: nil)
        } else {
            updateExactPitchView()
            updateOutOfTuneLabels()
        }
    }

    private func updateExactPitchView() {
        guard let centOffset = centOffset else {
            exactPitchView.alpha = 0
            return
        }

        exactPitchView.alpha = 1
        let usableWidth = accuracyView.bounds.width - exactPitchView.bounds.width
        exactPitchView.center.x = exactPitchView.bounds.width / 2 + usableWidth * CGFloat(centOffset + 50) / 100

        if inTuneCentRange.contains(centOffset) {
            exactPitchView.backgroundColor = self.tintColor.withAlphaComponent(0.5)
        } else {
            exactPitchView.backgroundColor = nil
        }
    }

    private func updateOutOfTuneLabels() {
        guard let centOffset = centOffset else {
            tooLowLabel.alpha = 0
            tooHighLabel.alpha = 0
            inTuneLabel.alpha = 0
            return
        }

        if centOffset < inTuneCentRange.lowerBound {
            tooLowLabel.alpha = 1
        } else {
            tooLowLabel.alpha = 0
        }

        if centOffset > inTuneCentRange.upperBound {
            tooHighLabel.alpha = 1
        } else {
            tooHighLabel.alpha = 0
        }

        if inTuneCentRange.contains(centOffset) {
            inTuneLabel.alpha = 1
        } else {
            inTuneLabel.alpha = 0
        }
    }

}
