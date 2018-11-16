//
//  Pitch.swift
//  Cello Mute
//
//  Created by William Ma on 11/14/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import Foundation

struct Pitch {

    private var adjustedAbsoluteCents: Int

    var octave: Int {
        return adjustedAbsoluteCents / 1200
    }
    var semitone: Int {
        return adjustedAbsoluteCents / 100 % 12
    }
    var cents: Int {
        return adjustedAbsoluteCents % 100 - 50
    }
    var absoluteCents: Int {
        return adjustedAbsoluteCents - 50
    }
    var frequency: Double {
        return 440 * pow(2, Double(absoluteCents - 5700) / 1200)
    }

    init?(frequency: Double) {
        guard frequency > 0 else {
            return nil
        }

        adjustedAbsoluteCents = 5700 + Int(round(1200 * log2(frequency / 440))) + 50

        if (adjustedAbsoluteCents < 50) {
            return nil
        }
    }

    init?(octave: Int, semitone: Int, cents: Int) {
        adjustedAbsoluteCents = 1200 * octave + 100 * semitone + cents + 50

        if (adjustedAbsoluteCents < 50) {
            return nil
        }
    }

    init?(absoluteCents: Int) {
        adjustedAbsoluteCents = absoluteCents + 50

        if (adjustedAbsoluteCents < 50) {
            return nil
        }
    }

    func closestNote(using accidental: Note.PitchChangingAccidental = .sharp) -> Note {
        return Note(name: Note.semitones(using: accidental)[semitone], octave: octave)
    }

}

extension Pitch: Equatable {
    
}

extension Pitch: CustomDebugStringConvertible {

    var debugDescription: String {
        return "(adjustedAbsoluteCents: \(adjustedAbsoluteCents), octave: \(octave), semitone: \(semitone), cents: \(cents))"
    }

}
