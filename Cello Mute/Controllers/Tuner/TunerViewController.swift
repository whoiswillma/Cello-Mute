//
//  TunerViewController.swift
//  Cello Mute
//
//  Created by William Ma on 11/13/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import AudioKit
import UIKit

class TunerViewController: UIViewController {

    // views

    @IBOutlet private weak var headerViewContainer: UIView!
    private var headerView: TunerHeaderView!

    // model

    var tuner: Tuner!

    // controller

    override func viewDidLoad() {
        super.viewDidLoad()

        headerView = TunerHeaderView.loadFromNib()
        headerViewContainer.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: headerViewContainer.topAnchor),
            headerView.leftAnchor.constraint(equalTo: headerViewContainer.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: headerViewContainer.rightAnchor),
            headerView.bottomAnchor.constraint(equalTo: headerViewContainer.bottomAnchor)
            ])

        tuner = Tuner()
        tuner.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tuner.startTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tuner.stopTracking()
    }

}

extension TunerViewController: TunerDelegate {

    func tunerDidStartTracking(_ tuner: Tuner) {
        print("Tuner started tracking")

    }

    func tunerDidStopTracking(_ tuner: Tuner) {
        print("Tuner stopped tracking")

        headerView.trackingStatus = .notTracking
        headerView.pitch = nil
    }

    func tunerDidBeginInactivelyTracking(_ tuner: Tuner) {
        headerView.trackingStatus = .inactivelyTracking
    }

    func tunerDidEndInactivelyTracking(_ tuner: Tuner) {
    }

    func tunerDidBeginActivelyTracking(_ tuner: Tuner) {
        headerView.trackingStatus = .activelyTracking
    }

    func tunerDidEndActivelyTracking(_ tuner: Tuner) {
    }

    func tuner(_ tuner: Tuner, didSample pitch: Pitch) {
        headerView.pitch = pitch
    }

}


