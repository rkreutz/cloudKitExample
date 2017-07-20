//
//  Pokemon.swift
//  webServerPokemon
//
//  Created by Rodrigo Kreutz on 2/29/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import UIKit

class Pokemon: NSObject {
    
    var number: Int!
    var name: String!
    var icon: String!
    var image: String!
    var level: Int!
    var type: String!
    var type2: String?
    var status: Status!
    var skills: [Skill]! = []
    
    init(number: Int?, name: String?, icon: String?, image: String?, level: Int?, type: String?, type2: String?, status: NSDictionary?, skills: NSArray?) {
        super.init()
        
        if let number = number {
            self.number = number
        }
        
        if let name = name {
            self.name = name
        }
        
        if let icon = icon {
            self.icon = icon
        }
        
        if let image = image {
            self.image = image
        }
        
        if let level = level {
            self.level = level
        }
        
        if let type = type {
            self.type = type
        }
        
        self.type2 = type2
        
        if let status = status {
            self.status = Status(health: status.objectForKey("health") as? Int, attack: status.objectForKey("attack") as? Int, defense: status.objectForKey("defense") as? Int, spAttack: status.objectForKey("spAttack") as? Int, spDefense: status.objectForKey("spDefense") as? Int, speed: status.objectForKey("speed") as? Int)
        }
        
        if let skills = skills {
            for skill in skills {
                self.skills.append(Skill(name: skill.objectForKey("name") as? String, type: skill.objectForKey("type") as? String, damage: skill.objectForKey("damageCategory") as? String, power: skill.objectForKey("power") as? Int, accuracy: skill.objectForKey("accuracy") as? Int, powerPoint: skill.objectForKey("powerPoint") as? Int))
            }
        }
    }
    
}
