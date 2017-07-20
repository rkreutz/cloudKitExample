//
//  Status.swift
//  webServerPokemon
//
//  Created by Rodrigo Kreutz on 2/29/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import UIKit

class Status: NSObject {
    
    var health: Int!
    var attack: Int!
    var defense: Int!
    var spAttack: Int!
    var spDefense: Int!
    var speed: Int!
    
    init(health: Int?, attack: Int?, defense: Int?, spAttack: Int?, spDefense: Int?, speed: Int?) {
        super.init()
        
        if let health = health {
            self.health = Int(health)
        }
        
        if let attack = attack {
            self.attack = Int(attack)
        }
        
        if let defense = defense {
            self.defense = Int(defense)
        }
        
        if let spAttack = spAttack {
            self.spAttack = Int(spAttack)
        }
        
        if let spDefense = spDefense {
            self.spDefense = Int(spDefense)
        }
        
        if let speed = speed {
            self.speed = Int(speed)
        }
    }
}
