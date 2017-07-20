//
//  Skill.swift
//  webServerPokemon
//
//  Created by Rodrigo Kreutz on 2/29/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import UIKit

class Skill: NSObject {
    
    var name: String!
    var type: String!
    var damageCategory: String!
    var power: Int!
    var accuracy: Int!
    var powerPoint: Int!
    
    init(name: String?, type: String?, damage: String?, power: Int?, accuracy: Int?, powerPoint: Int?) {
        super.init()
        
        if let name = name {
            self.name = name
        }
        
        if let type = type {
            self.type = type
        }
        
        if let damage = damage {
            self.damageCategory = damage
        }
        
        if let power = power {
            self.power = Int(power)
        }
        
        if let accuracy = accuracy {
            self.accuracy = Int(accuracy)
        }
        
        if let powerPoint = powerPoint {
            self.powerPoint = Int(powerPoint)
        }
    }
}
