//
//  TenorEngineComponent.swift
//  Cello Mute
//
//  Created by William Ma on 11/19/18.
//  Copyright © 2018 William Ma. All rights reserved.
//

import AudioKit
import Foundation

protocol TenorEngineComponent {

    var output: AKNode { get }

    init()

}
