//
//  SettingsTableViewController.swift
//  Cello Mute
//
//  Created by William Ma on 1/1/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import SwiftNotificationCenter
import SafariServices
import SwiftyUserDefaults
import UIKit

/**
 Notifies observers that the values of the defaults keys of settings have changed
 */
protocol SettingsDefaultsObserving {

    func reloadSettingsFromDefaults()

}

class SettingsTableViewController: UITableViewController {

    private struct CreditSource {

        let title: String
        let url: URL?

    }

    enum CellIdentifier {

        case sectionTitle
        case flatsSharps

        case tunerInTuneLevel
        case tunerActivationVolumeLevel

        case metronomePreciseSelection

        case credit

        var value: String {
            switch self {
            case .sectionTitle: return "sectionTitle"
            case .flatsSharps: return "flatsSharps"
            case .tunerInTuneLevel: return "tuner.inTuneLevel"
            case .tunerActivationVolumeLevel: return "tuner.activationVolumeLevel"
            case .metronomePreciseSelection: return "metronome.preciseSelection"
            case .credit: return "credits.credit"
            }
        }

    }

    private let creditSources = [
        CreditSource(title: "AudioKit", url: URL(string: "https://audiokit.io/")),
        CreditSource(title: "NotificationBanner", url: URL(string: "https://github.com/Daltron/NotificationBanner")),
        CreditSource(title: "SwiftNotificationCenter", url: URL(string: "https://github.com/100mango/SwiftNotificationCenter")),
        CreditSource(title: "SwiftyUserDefaults", url: URL(string: "https://github.com/radex/SwiftyUserDefaults")),
    ]

    private var settings: Settings!

    override func viewDidLoad() {
        super.viewDidLoad()

        settings = Defaults[.settings]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 2, 3, 4, 5, 6, 7, 8: return 1
        case 9: return creditSources.count
        default: return 0
        }
    }

    private func cellIdentifier(forRowAt indexPath: IndexPath) -> CellIdentifier? {
        switch indexPath.section {
        case 0: return .sectionTitle
        case 1: return .flatsSharps
        case 2: return .tunerInTuneLevel
        case 3: return .tunerActivationVolumeLevel
        case 4: return .sectionTitle
        case 5: return .metronomePreciseSelection
        case 6: return .sectionTitle
        case 7: return .flatsSharps
        case 8: return .sectionTitle
        case 9: return .credit
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let identifier = cellIdentifier(forRowAt: indexPath) else {
            return UITableViewCell()
        }

        switch identifier {
        case .sectionTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.value, for: indexPath) as! SectionTitleTableViewCell

            switch indexPath.section {
            case 0: cell.title = "Tuner"
            case 4: cell.title = "Metronome"
            case 6: cell.title = "Generator"
            case 8: cell.title = "Credits"
            default: cell.title = ""
            }

            return cell

        case .flatsSharps:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.value, for: indexPath) as! FlatsSharpsTableViewCell

            switch indexPath.section {
            case 1:
                cell.accidental = settings.tuner.accidental
                cell.accidentalDidChange = { [weak self] in
                    self?.settings.tuner.accidental = cell.accidental
                }
            case 7:
                cell.accidental = settings.generator.accidental
                cell.accidentalDidChange = { [weak self] in
                    self?.settings.generator.accidental = cell.accidental
                }
            default:
                break
            }

            return cell

        case .tunerInTuneLevel:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.value, for: indexPath) as! TunerInTuneLevelTableViewCell

            cell.inTuneLevel = settings.tuner.inTuneLevel
            cell.inTuneLevelDidChange = { [weak self] in
                self?.settings.tuner.inTuneLevel = cell.inTuneLevel
            }

            return cell

        case .tunerActivationVolumeLevel:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.value, for: indexPath) as! TunerActivationVolumeLevelTableViewCell

            cell.activationVolumeLevel = settings.tuner.activationVolumeLevel
            cell.activationVolumeLevelDidChange = { [weak self] in
                self?.settings.tuner.activationVolumeLevel = cell.activationVolumeLevel
            }

            return cell

        case .metronomePreciseSelection:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.value, for: indexPath) as! MetronomePreciseSelctionTableViewCell

            cell.enabled = settings.metronome.preciseSelection
            cell.enabledValueChanged = { [weak self] in
                self?.settings.metronome.preciseSelection = cell.enabled
            }

            return cell

        case .credit:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.value, for: indexPath) as! CreditTableViewCell

            cell.title = creditSources[indexPath.row].title

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let identifier = cellIdentifier(forRowAt: indexPath) else {
            print("Cell with invalid identifier selected")
            return
        }

        switch identifier {
        case .credit:
            guard let url = creditSources[indexPath.row].url else {
                print("Could not get url from credit titled: \(creditSources[indexPath.row].title)")
                break
            }

            let svc = SFSafariViewController(url: url)
            svc.preferredControlTintColor = view.tintColor
            present(svc, animated: true)

        case .flatsSharps, .metronomePreciseSelection, .tunerInTuneLevel, .tunerActivationVolumeLevel, .sectionTitle:
            break
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2: return "Select how far from the exact pitch you need to be \"in tune\"."
        case 3: return "Select how loud you must play for the tuner to begin analyzing sound"
        case 5: return "Enabling this will allow you to select from any BPM"
        default: return nil
        }
    }

    @IBAction private func doneButtonPressed() {
        print("Reloading settings from defaults")

        Defaults[.settings] = settings

        Broadcaster.notify(SettingsDefaultsObserving.self) { $0.reloadSettingsFromDefaults() }
        dismiss(animated: true)
    }

}
