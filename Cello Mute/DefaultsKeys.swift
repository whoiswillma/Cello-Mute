//
//  DefaultsKeys.swift
//  Cello Mute
//
//  Created by William Ma on 1/12/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import SwiftyUserDefaults
import Foundation

extension DefaultsKeys {

    static let settings = DefaultsKey<Settings>("com.williamma.Cello-Mute.DefaultsKeys.settings", defaultValue: Settings())

}
