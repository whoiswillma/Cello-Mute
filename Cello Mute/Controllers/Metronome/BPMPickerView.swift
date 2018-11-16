//
//  BPMPickerView.swift
//  Cello Mute
//
//  Created by William Ma on 12/16/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit

protocol BPMPickerViewDelegate: AnyObject {

    func bpmPickerView(_ bpmPickerView: BPMPickerView, didSelectBPM bpm: Int)

}

class BPMPickerView: UIView {

    @IBOutlet private var pickerView: UIPickerView!

    var allowsPreciseSelection: Bool = false {
        didSet {
            if let pickerView = pickerView {
                let oldBpm = bpm
                pickerView.reloadAllComponents()
                selectBpm(closestTo: oldBpm, animated: false)
            }
        }
    }

    var bpm: Int {
        return bpm(for: pickerView.selectedRow(inComponent: 0))
    }

    private let bpmRange = MetronomeViewController.bpmRange

    weak var delegate: BPMPickerViewDelegate?

    private var rowCount: Int {
        if allowsPreciseSelection {
            return bpmRange.upperBound - bpmRange.lowerBound + 1
        } else {
            var rows = 0
            while impreciseBpm(for: rows) <= bpmRange.upperBound {
                rows += 1
            }
            return rows
        }
    }

    // Invariant: this function must be strictly increasing for non-negative values of row
    private func preciseBpm(for row: Int) -> Int {
        return row + bpmRange.lowerBound
    }

    // Invariant: this function must be strictly increasing for non-negative values of row
    private func impreciseBpm(for row: Int) -> Int {
        return 4 * row + bpmRange.lowerBound
    }

    private func bpm(for row: Int) -> Int {
        return allowsPreciseSelection ? preciseBpm(for: row) : impreciseBpm(for: row)
    }

    func selectBpm(closestTo bpm: Int, animated: Bool) {
        if allowsPreciseSelection {
            let row = (0...(rowCount - 1)).clamp(bpm - bpmRange.lowerBound)
            pickerView.selectRow(row, inComponent: 0, animated: animated)
        } else {
            if bpm < bpmRange.lowerBound {
                pickerView.selectRow(0, inComponent: 0, animated: animated)
            } else if bpm > bpmRange.upperBound {
                pickerView.selectRow(rowCount - 1, inComponent: 0, animated: animated)
            } else {
                let rowOfLowerBound = (0..<rowCount).first(where: { impreciseBpm(for: $0 + 1) > bpm }) ?? 0
                pickerView.selectRow(rowOfLowerBound, inComponent: 0, animated: animated)
            }
        }
    }

}

extension BPMPickerView: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rowCount
    }

}

extension BPMPickerView: UIPickerViewDelegate {

    private static var font: UIFont = {
        let fontSize = 1.5 * UIFont.preferredFont(forTextStyle: .body).pointSize
        return UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }()

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()

        label.text = "\(bpm(for: row))"
        label.font = BPMPickerView.font
        label.sizeToFit()

        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let label = UILabel()

        label.text = "\(bpmRange.upperBound)"
        label.font = BPMPickerView.font
        label.sizeToFit()

        return label.bounds.height + 4
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.bpmPickerView(self, didSelectBPM: bpm(for: row))
    }

}
