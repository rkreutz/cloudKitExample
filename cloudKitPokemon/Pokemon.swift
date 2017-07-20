//
//  Pokemon.swift
//  webServerPokemon
//
//  Created by Rodrigo Kreutz on 2/29/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import UIKit
import CloudKit

class Pokemon: NSObject {
    
    var number: Int!
    var name: String!
    var icon: UIImage!
    var image: UIImage!
    var level: Int!
    var type: String!
    var type2: String?
    var status: Status!
    var skills: [Skill]! = []
    var recordName: String!
    var favorite: Bool = false
    var imageAsset: CKAsset!
    var iconAsset: CKAsset!
    
    init(number: Int?, name: String?, icon: CKAsset?, image: CKAsset?, level: Int?, type: String?, type2: String?, recordName: String?) {
        super.init()
        
        if let number = number {
            self.number = number
        }
        
        if let name = name {
            self.name = name
        }
        
        if let icon = icon {
            self.iconAsset = icon
            if let data = NSData(contentsOfURL: icon.fileURL) {
                self.icon = UIImage(data: data)
            }
        }
        
        if let image = image {
            self.imageAsset = image
            if let data = NSData(contentsOfURL: image.fileURL) {
                self.image = UIImage(data: data)
            }
        }
        
        if let level = level {
            self.level = level
        }
        
        if let type = type {
            self.type = type
        }
        
        self.type2 = type2
        
        self.status = nil
        self.skills = []
        
        if let recordName = recordName {
            self.recordName = recordName
        }
    }
    
    init(number: Int?, name: String?, icon: String?, image: String?, level: Int?, type: String?, type2: String?, status: NSDictionary?, skills: NSArray?) {
        super.init()
        
        if let number = number {
            self.number = number
        }
        
        if let name = name {
            self.name = name
        }
        
        if let icon = icon {
            if let icon = NSURL(string: icon) {
                if let data = NSData(contentsOfURL: icon) {
                    self.icon = UIImage(data: data)
                    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
                    if paths.count > 0 {
                        let writePath = paths[0].stringByAppendingString("/\(self.name.lowercaseString)-icon.png")
                        UIImagePNGRepresentation(self.icon)?.writeToFile(writePath, atomically: true)
                        self.iconAsset = CKAsset(fileURL: NSURL.fileURLWithPath(writePath))
                    }
                }
            }
        }
        
        if let image = image {
            if let image = NSURL(string: image) {
                if let data = NSData(contentsOfURL: image) {
                    self.image = UIImage(data: data)
                    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
                    if paths.count > 0 {
                        let writePath = paths[0].stringByAppendingString("/\(self.name.lowercaseString)-image.png")
                        UIImagePNGRepresentation(self.image)?.writeToFile(writePath, atomically: true)
                        self.imageAsset = CKAsset(fileURL: NSURL.fileURLWithPath(writePath))
                    }
                }
            }
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
                if let skill = skill as? NSDictionary {
                    self.skills.append(Skill(name: skill.objectForKey("name") as? String, type: skill.objectForKey("type") as? String, damage: skill.objectForKey("damageCategory") as? String, power: skill.objectForKey("power") as? Int, accuracy: skill.objectForKey("accuracy") as? Int, powerPoint: skill.objectForKey("powerPoint") as? Int))
                }
            }
        }
    }
    
}
