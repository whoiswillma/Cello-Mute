//
//  Resources.swift
//  Cello Mute
//
//  Created by William Ma on 12/28/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import Foundation

enum Resources {

    enum WoodBlock {

        enum High {

            static let emphasized = Bundle.main.url(forResource: "WB-High-Em", withExtension: "wav")!
            static let normal = Bundle.main.url(forResource: "WB-High-Norm", withExtension: "wav")!
            static let subdivision = Bundle.main.url(forResource: "WB-High-Sub", withExtension: "wav")!

        }

        enum Medium {

            static let emphasized = Bundle.main.url(forResource: "WB-Med-Em", withExtension: "wav")!
            static let normal = Bundle.main.url(forResource: "WB-Med-Norm", withExtension: "wav")!
            static let subdivision = Bundle.main.url(forResource: "WB-Med-Sub", withExtension: "wav")!

        }

    }

}
