//
//  AppDelegate.swift
//  Cello Mute
//
//  Created by William Ma on 11/13/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import UIKit
import AudioKit
import NotificationBannerSwift
import SwiftNotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder {

    static let shared = UIApplication.shared.delegate as! AppDelegate

    var window: UIWindow?

    private var started: Bool = false

    private var tuner: Tuner! {
        didSet {
            if let initialization = tunerInitialized {
                initialization(tuner)
            }
        }
    }
    var tunerInitialized: ((Tuner) -> Void)! {
        didSet {
            if let tuner = tuner {
                tunerInitialized(tuner)
            }
        }
    }

    private var metronome: Metronome! {
        didSet {
            if let initialization = metronomeInitialized {
                initialization(metronome)
            }
        }
    }
    var metronomeInitialized: ((Metronome) -> Void)! {
        didSet {
            if let metronome = metronome {
                metronomeInitialized(metronome)
            }
        }
    }

    private var generator: Generator! {
        didSet {
            if let initialization = generatorInitialized {
                initialization(generator)
            }
        }
    }
    var generatorInitialized: ((Generator) -> Void)! {
        didSet {
            if let generator = generator {
                generatorInitialized(generator)
            }
        }
    }

}

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.tint
        ]

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        do {
            try startEngine()
        } catch {
            let message = """
            It seems as if Cello Mute is unable to process audio.
            This can happen for many reasons that I am uncertain of.

            Here is the exact error message: "\(error.localizedDescription)"
            """
            let alert = UIAlertController(title: "This is awkward", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close App", style: .destructive) { _ in
                fatalError("Unable to start engine: \(error.localizedDescription)")
            })
            window?.rootViewController?.present(alert, animated: true)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        Broadcaster.notify(AppStateObserver.self) { $0.applicationWillResignActive(application) }
    }

    private func startEngine() throws {
        guard !started else {
            return
        }

        print(AKSettings.sampleRate, AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate)
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        print(AKSettings.sampleRate, AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate)

        AKSettings.audioInputEnabled = true

        let tuner = Tuner()
        let metronome = Metronome()
        let generator = Generator()

        // audiokit

        let mixer = AKMixer(tuner.output, metronome.output, generator.output)
        AudioKit.output = mixer

        try AKSettings.setSession(category: .playAndRecord)
        //        try AKSettings.setSession(category: .playAndRecord, with: .mixWithOthers)
        AKSettings.defaultToSpeaker = true

        try AudioKit.start()

        started = true

        self.tuner = tuner
        self.metronome = metronome
        self.generator = generator
    }

}

protocol AppStateObserver {

    func applicationWillResignActive(_ application: UIApplication)

}
