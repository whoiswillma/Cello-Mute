//
//  Note.swift
//  Cello Mute
//
//  Created by William Ma on 11/13/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import Foundation

struct Note {

    enum Accidental {

        case flat
        case natural
        case sharp

        var text: String {
            switch self {
            case .flat: return "\u{266d}"
            case .natural: return "\u{266e}"
            case .sharp: return "\u{266f}"
            }
        }

        var semitoneAdjustment: Int {
            switch self {
            case .flat: return -1
            case .natural: return 0
            case .sharp: return 1
            }
        }

    }
    
    enum Name {

        case a(Accidental)
        case b(Accidental)
        case c(Accidental)
        case d(Accidental)
        case e(Accidental)
        case f(Accidental)
        case g(Accidental)

        var text: String {
            switch self {
            case let .a(accidental): return "A" + accidental.text
            case let .b(accidental): return "B" + accidental.text
            case let .c(accidental): return "C" + accidental.text
            case let .d(accidental): return "D" + accidental.text
            case let .e(accidental): return "E" + accidental.text
            case let .f(accidental): return "F" + accidental.text
            case let .g(accidental): return "G" + accidental.text
            }
        }

        var semitone: Int {
            switch self {
            case let .c(accidental): return 0 + accidental.semitoneAdjustment
            case let .d(accidental): return 2 + accidental.semitoneAdjustment
            case let .e(accidental): return 4 + accidental.semitoneAdjustment
            case let .f(accidental): return 5 + accidental.semitoneAdjustment
            case let .g(accidental): return 7 + accidental.semitoneAdjustment
            case let .a(accidental): return 9 + accidental.semitoneAdjustment
            case let .b(accidental): return 11 + accidental.semitoneAdjustment
            }
        }

    }

    static let semitonesUsingFlats: [Note.Name] = [
        .c(.natural),
        .d(.flat),
        .d(.natural),
        .e(.flat),
        .e(.natural),
        .f(.natural),
        .g(.flat),
        .g(.natural),
        .a(.flat),
        .a(.natural),
        .b(.flat),
        .b(.natural)
    ]

    static let semitonesUsingSharps: [Note.Name] = [
        .c(.natural),
        .c(.sharp),
        .d(.natural),
        .d(.sharp),
        .e(.natural),
        .f(.natural),
        .f(.sharp),
        .g(.natural),
        .g(.sharp),
        .a(.natural),
        .a(.sharp),
        .b(.natural),
    ]

    var octave: Int
    var name: Name

    var pitch: Pitch? {
        return Pitch(octave: octave, semitone: name.semitone, cents: 0)
    }

    init(name: Name, octave: Int) {
        self.octave = octave
        self.name = name
    }

    init(_ name: Name, _ octave: Int) {
        self.init(name: name, octave: octave)
    }

}

extension Note: Equatable {

    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.pitch == rhs.pitch
    }

}

extension Note: CustomDebugStringConvertible {

    var debugDescription: String {
        return "\(name.text)\(octave)"
    }

}
