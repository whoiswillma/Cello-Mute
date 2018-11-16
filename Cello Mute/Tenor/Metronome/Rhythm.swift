//
//  Rhythm.swift
//  Cello Mute
//
//  Created by William Ma on 12/25/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

struct Rhythm: Codable, DefaultsSerializable {

    static let commonTime = Rhythm(beatStyles: [BeatStyle](repeating: .normal, count: 4), subdivisionLevel: 1)!

    enum BeatStyle: String, Codable {

        case normal
        case emphasised
        case silent

    }

    let beatStyles: [BeatStyle]
    let subdivisionLevel: Int

    init?(beatStyles: [BeatStyle], subdivisionLevel: Int) {
        guard 1 <= beatStyles.count, beatStyles.count <= 8 else {
            return nil
        }
        self.beatStyles = beatStyles

        guard 1 <= subdivisionLevel, subdivisionLevel <= 4 else {
            return nil
        }
        self.subdivisionLevel = subdivisionLevel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let beatStyles = try container.decode([BeatStyle].self, forKey: .beatStyles)
        guard 1 <= beatStyles.count, beatStyles.count <= 8 else {
            let debugDescription = "beatStyles.count must be in the range [1, 8]"
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.beatStyles,
                                                   in: container,
                                                   debugDescription: debugDescription)
        }
        self.beatStyles = beatStyles

        let subdivisionLevel = try container.decode(Int.self, forKey: .subdivisionLevel)
        guard 1 <= subdivisionLevel, subdivisionLevel <= 4 else {
            let debugDescription = "subdivisionLevel must be in the range [1, 4]"
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.subdivisionLevel,
                                                   in: container,
                                                   debugDescription: debugDescription)
        }
        self.subdivisionLevel = subdivisionLevel
    }

    func withBeatStyles(_ beatStyles: [BeatStyle]) -> Rhythm? {
        return Rhythm(beatStyles: beatStyles, subdivisionLevel: subdivisionLevel)
    }

    func withSubdivisionLevel(_ subdivisionLevel: Int) -> Rhythm? {
        return Rhythm(beatStyles: beatStyles, subdivisionLevel: subdivisionLevel)
    }

}
