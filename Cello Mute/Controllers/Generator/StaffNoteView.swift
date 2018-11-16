//
//  StaffNoteView.swift
//  Cello Mute
//
//  Created by William Ma on 12/30/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit

class StaffNoteView: UIView {

    private let staffLines = (0..<10).map { _ in CALayer() }

    private let bassClef = UIImageView(image: UIImage(named: "BassClef"))
    private let trebleClef = UIImageView(image: UIImage(named: "TrebleClef"))

    private let noteBody = CAShapeLayer()
    private let noteStem = CALayer()
    private let middleCLedgerLine = CALayer()
    private let accidentalLabel = UILabel()

    private var staffLineDistance: CGFloat {
        return (3 / 5 * bounds.height) / 11
    }

    private var topStaffStart: CGFloat {
        return bounds.height * 1 / 5
    }

    private var bottomStaffStart: CGFloat {
        return bounds.height / 5 + 6 * staffLineDistance
    }

    private var middleCY: CGFloat {
        return topStaffStart + 5 * staffLineDistance
    }

    private let middleC = Note(name: .c(.natural), octave: 4)

    var note: Note? {
        didSet {
            layoutNote()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        for line in staffLines {
            line.backgroundColor = UIColor.black.cgColor

            layer.addSublayer(line)
        }

        bassClef.contentMode = .scaleAspectFit
        bassClef.layer.minificationFilter = .trilinear
        addSubview(bassClef)

        trebleClef.contentMode = .scaleAspectFit
        trebleClef.layer.minificationFilter = .trilinear
        addSubview(trebleClef)

        noteBody.fillColor = UIColor.black.cgColor
        noteBody.strokeColor = nil
        noteBody.isHidden = true
        layer.addSublayer(noteBody)

        noteStem.backgroundColor = UIColor.black.cgColor
        noteStem.isHidden = true
        layer.addSublayer(noteStem)

        middleCLedgerLine.backgroundColor = UIColor.black.cgColor
        middleCLedgerLine.isHidden = true
        layer.addSublayer(middleCLedgerLine)

        accidentalLabel.font = .systemFont(ofSize: 28)
        accidentalLabel.isHidden = true
        addSubview(accidentalLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutNote()
        layoutStaffLines()
        layoutClefs()
        layoutMiddleCLedgerLine()
    }

    private func layoutNote() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        defer {
            CATransaction.commit()
        }

        guard let note = note, abs(middleC.staffLineDifference(to: note)) <= 10 else {
            noteBody.isHidden = true
            noteStem.isHidden = true
            middleCLedgerLine.isHidden = true
            accidentalLabel.isHidden = true
            return
        }

        let staffLineDifference = middleC.staffLineDifference(to: note)

        noteBody.isHidden = false
        noteStem.isHidden = false
        middleCLedgerLine.isHidden = staffLineDifference != 0

        // construct a line y = mx + b such that x is the semitone difference and y is the y-coordinate of the center of
        // the body of the note
        let centerY = -(staffLineDistance / 2) * CGFloat(staffLineDifference) + middleCY

        let height = staffLineDistance
        let width = 5 / 4 * height

        let bodyPath = UIBezierPath(ovalIn: CGRect(x: bounds.midX - width / 2,
                                                   y: centerY - height / 2,
                                                   width: width,
                                                   height: height))
        noteBody.path = bodyPath.cgPath

        let stemHeight = (7 / 2) * staffLineDistance
        if staffLineDifference < 0 {
            noteStem.frame = CGRect(x: bounds.midX + width / 2,
                                    y: centerY,
                                    width: -2,
                                    height: -stemHeight)
        } else {
            noteStem.frame = CGRect(x: bounds.midX - width / 2,
                                    y: centerY,
                                    width: 2,
                                    height: stemHeight)
        }

        if note.name.accidental != .natural {
            accidentalLabel.isHidden = false

            accidentalLabel.text = note.name.accidental.text
            accidentalLabel.sizeToFit()

            accidentalLabel.frame = CGRect(x: bounds.midX - width / 2 - accidentalLabel.bounds.width,
                                           y: centerY - accidentalLabel.bounds.height / 2,
                                           width: accidentalLabel.bounds.width,
                                           height: accidentalLabel.bounds.height)
        } else {
            accidentalLabel.isHidden = true
        }
    }

    private func layoutStaffLines() {
        for (i, line) in staffLines[0..<5].enumerated() {
            line.frame = CGRect(x: 0,
                                 y: topStaffStart + CGFloat(i) * staffLineDistance,
                                 width: bounds.width,
                                 height: 1)
        }

        for (i, line) in staffLines[5..<10].enumerated() {
            line.frame = CGRect(x: 0,
                                 y: bottomStaffStart + CGFloat(i) * staffLineDistance,
                                 width: bounds.width,
                                 height: 1)
        }
    }

    private func layoutClefs() {
        layoutTrebleClef()
        layoutBassClef()
    }

    private func layoutTrebleClef() {
        // This method produces a linear function f(x) = y such that x is a value between 0 and 1 representing a
        // y-coordinate on the treble clef image of unit height, and f(x) is the y-coordinate in the bounds of this view

        // two reference y-coordinates
        let y3 = topStaffStart + 2 * staffLineDistance
        let y5 = topStaffStart + 4 * staffLineDistance

        // two reference x-coordinates, approximated by looking at the image
        let x3: CGFloat = 576 / 1197
        let x5: CGFloat = 890 / 1197

        // slope
        let m = (y5 - y3) / (x5 - x3)

        let f0 = m * (0 - x3) + y3 // f(0)
        let f1 = m * (1 - x3) + y3 // f(1)

        let height = f1 - f0

        // then, compute the width based on the aspect ratio and height
        let aspectRatio: CGFloat = 532 / 1197
        let width = aspectRatio * height

        trebleClef.frame = CGRect(x: 24, y: f0, width: width, height: height)
    }

    private func layoutBassClef() {
        // This method is similar to the treble clef method

        let y1 = bottomStaffStart + 0 * staffLineDistance
        let y2 = bottomStaffStart + 1 * staffLineDistance

        let x1: CGFloat = 0 / 2222
        let x2: CGFloat = 657 / 2222

        let m = (y2 - y1) / (x2 - x1)

        let f0 = m * (0 - x2) + y2
        let f1 = m * (1 - x2) + y2

        let height = f1 - f0

        let aspectRatio: CGFloat = 2000 / 2222
        let width = aspectRatio * height

        bassClef.frame = CGRect(x: 24, y: f0, width: width, height: height)
    }

    private func layoutMiddleCLedgerLine() {
        let width = 2 * (5 / 4 * staffLineDistance)
        middleCLedgerLine.frame = CGRect(x: bounds.midX - width / 2, y: middleCY, width: width, height: 1)
    }

}

private extension Note.Name {

    /**
     The note number in a C scale, starting with 0, i.e. C => 0, D => 1, G => 4 ignoring accidentals
     */
    var number: Int {
        switch self {
        case .c(_): return 0
        case .d(_): return 1
        case .e(_): return 2
        case .f(_): return 3
        case .g(_): return 4
        case .a(_): return 5
        case .b(_): return 6
        }
    }

}

private extension Note {

    func staffLineDifference(to other: Note) -> Int {
        return (7 * other.octave + other.name.number) - (7 * octave + name.number)
    }

}
