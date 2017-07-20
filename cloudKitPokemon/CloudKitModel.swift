//
//  CloudKitModel.swift
//  cloudKitPokemon
//
//  Created by Rodrigo Kreutz on 3/8/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import UIKit
import CloudKit

protocol CloudKitModelDelegate {
    func logStatus(error: NSError?)
    func refreshData(pokemons: [Pokemon]?, withError error: NSError?)
    func addedData(withError: NSError?)
}

class CloudKitModel: NSObject {

    static let sharedInstance = CloudKitModel()
    
    var delegate: CloudKitModelDelegate?
    var userRecord: CKRecordID?
    var container: CKContainer!
    
    func checkICloudCredentials(container: CKContainer) {
        container.fetchUserRecordIDWithCompletionHandler { (recordId: CKRecordID?, error: NSError?) -> Void in
            self.userRecord = recordId
            self.container = container
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.logStatus(error)
            }
        }
    }
    
    func refreshData(sender: AnyObject) {
        if let _ = self.userRecord {
            let predicate = NSPredicate(value: true)
            let queryPokemon = CKQuery(recordType: "Pokemon", predicate: predicate)
            
            self.container.publicCloudDatabase.performQuery(queryPokemon, inZoneWithID: nil) { (fetchedPokemons: [CKRecord]?, errPokemons: NSError?) -> Void in
                if let error = errPokemons {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.refreshData(nil, withError: error)
                    }
                }
                else {
                    let queryStats = CKQuery(recordType: "Status", predicate: predicate)
                    
                    self.container.publicCloudDatabase.performQuery(queryStats, inZoneWithID: nil) { (fetchedStats: [CKRecord]?, errStats: NSError?) -> Void in
                        if let error = errStats {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.delegate?.refreshData(nil, withError: error)
                            }
                        }
                        else {
                            let querySkills = CKQuery(recordType: "Skill", predicate: predicate)
                            
                            self.container.publicCloudDatabase.performQuery(querySkills, inZoneWithID: nil) { (fetchedSkills: [CKRecord]?, errSkills: NSError?) -> Void in
                                if let error = errSkills {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.delegate?.refreshData(nil, withError: error)
                                    }
                                }
                                else {
                                    let queryFav = CKQuery(recordType: "Favorite", predicate: predicate)
                                    
                                    self.container.privateCloudDatabase.performQuery(queryFav, inZoneWithID: nil) { (fetchedFav: [CKRecord]?, errFav: NSError?) -> Void in
                                        if let error = errFav {
                                            dispatch_async(dispatch_get_main_queue()) {
                                                self.delegate?.refreshData(nil, withError: error)
                                            }
                                        }
                                        else {
                                            var pokemonsArray: [Pokemon]! = []
                                            if let pokemons = fetchedPokemons {
                                                for pokemon in pokemons {
                                                    let poke = Pokemon(number: pokemon["number"] as? Int, name: pokemon["name"] as? String, icon: pokemon["icon"] as? CKAsset, image: pokemon["image"] as? CKAsset, level: pokemon["level"] as? Int, type: pokemon["type1"] as? String, type2: pokemon["type2"] as? String, recordName: pokemon.recordID.recordName)
                                                    
                                                    pokemonsArray.append(poke)
                                                }
                                                
                                                if let stats = fetchedStats {
                                                    for stat in stats {
                                                        let statPoke = Status(health: stat["health"] as? Int, attack: stat["attack"] as? Int, defense: stat["defense"] as? Int, spAttack: stat["spAttack"] as? Int, spDefense: stat["spDefense"] as? Int, speed: stat["speed"] as? Int)
                                                        
                                                        for pokemon in pokemonsArray {
                                                            if pokemon.recordName == stat["pokemon"] as! String {
                                                                pokemon.status = statPoke
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                if let skills = fetchedSkills {
                                                    for skill in skills {
                                                        let skillPoke = Skill(name: skill["name"] as? String, type: skill["type"] as? String, damage: skill["damageCategory"] as? String, power: skill["power"] as? Int, accuracy: skill["accuracy"] as? Int, powerPoint: skill["powerPoint"] as? Int)
                                                        
                                                        for pokemon in pokemonsArray {
                                                            if pokemon.recordName == skill["pokemon"] as! String {
                                                                pokemon.skills.append(skillPoke)
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                if let favs = fetchedFav {
                                                    for fav in favs {
                                                        for pokemon in pokemonsArray {
                                                            if pokemon.recordName == fav["pokemon"] as! String {
                                                                pokemon.favorite = true
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            dispatch_async(dispatch_get_main_queue()) {
                                                self.delegate?.refreshData(pokemonsArray, withError: nil)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        else {
            self.checkICloudCredentials(self.container)
        }
    }
    
    func addPokemon(pokemon: Pokemon) {
        if let _ = self.userRecord {
            let pokemonCK = CKRecord(recordType: "Pokemon")
            pokemonCK.setValue(pokemon.name, forKey: "name")
            pokemonCK.setValue(pokemon.number, forKey: "number")
            pokemonCK.setValue(pokemon.iconAsset, forKey: "icon")
            pokemonCK.setValue(pokemon.imageAsset, forKey: "image")
            pokemonCK.setValue(pokemon.level, forKey: "level")
            pokemonCK.setValue(pokemon.type, forKey: "type1")
            pokemonCK.setValue(pokemon.type2, forKey: "type2")
            
            let statusCK = CKRecord(recordType: "Status")
            statusCK.setValue(pokemon.status.health, forKey: "health")
            statusCK.setValue(pokemon.status.attack, forKey: "attack")
            statusCK.setValue(pokemon.status.defense, forKey: "defense")
            statusCK.setValue(pokemon.status.spAttack, forKey: "spAttack")
            statusCK.setValue(pokemon.status.spDefense, forKey: "spDefense")
            statusCK.setValue(pokemon.status.speed, forKey: "speed")
            statusCK.setValue(pokemonCK.recordID.recordName, forKey: "pokemon")
            
            var skillsCK: [CKRecord]! = []
            for skill in pokemon.skills {
                let tmp = CKRecord(recordType: "Skill")
                tmp.setValue(skill.name, forKey: "name")
                tmp.setValue(skill.type, forKey: "type")
                tmp.setValue(skill.damageCategory, forKey: "damageCategory")
                tmp.setValue(skill.power, forKey: "power")
                tmp.setValue(skill.accuracy, forKey: "accuracy")
                tmp.setValue(skill.powerPoint, forKey: "powerPoint")
                tmp.setValue(pokemonCK.recordID.recordName, forKey: "pokemon")
                
                skillsCK.append(tmp)
            }
            
            var recordsToSave = skillsCK
            recordsToSave.append(pokemonCK)
            recordsToSave.append(statusCK)
            
            let recordsOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
            recordsOperation.savePolicy = .AllKeys
            recordsOperation.modifyRecordsCompletionBlock = { (records: [CKRecord]?, recordsId: [CKRecordID]?, error: NSError?) -> Void in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.addedData(error)
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.addedData(nil)
                    }
                }
            }
            
            self.container.publicCloudDatabase.addOperation(recordsOperation)
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.addedData(NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: 1, userInfo: [NSLocalizedDescriptionKey: "User is not logged on iCloud."]))
            }
        }
    }
    
    func addMultiplePokemons(pokemons: [Pokemon]) {
        if let _ = self.userRecord {
            var recordsToSavePublic = [CKRecord]()
            
            for pokemon in pokemons {
                let pokemonCK = CKRecord(recordType: "Pokemon")
                pokemonCK.setValue(pokemon.name, forKey: "name")
                pokemonCK.setValue(pokemon.number, forKey: "number")
                pokemonCK.setValue(pokemon.iconAsset, forKey: "icon")
                pokemonCK.setValue(pokemon.imageAsset, forKey: "image")
                pokemonCK.setValue(pokemon.level, forKey: "level")
                pokemonCK.setValue(pokemon.type, forKey: "type1")
                pokemonCK.setValue(pokemon.type2, forKey: "type2")
                
                let statusCK = CKRecord(recordType: "Status")
                statusCK.setValue(pokemon.status.health, forKey: "health")
                statusCK.setValue(pokemon.status.attack, forKey: "attack")
                statusCK.setValue(pokemon.status.defense, forKey: "defense")
                statusCK.setValue(pokemon.status.spAttack, forKey: "spAttack")
                statusCK.setValue(pokemon.status.spDefense, forKey: "spDefense")
                statusCK.setValue(pokemon.status.speed, forKey: "speed")
                statusCK.setValue(pokemonCK.recordID.recordName, forKey: "pokemon")
                
                var skillsCK: [CKRecord]! = []
                for skill in pokemon.skills {
                    let tmp = CKRecord(recordType: "Skill")
                    tmp.setValue(skill.name, forKey: "name")
                    tmp.setValue(skill.type, forKey: "type")
                    tmp.setValue(skill.damageCategory, forKey: "damageCategory")
                    tmp.setValue(skill.power, forKey: "power")
                    tmp.setValue(skill.accuracy, forKey: "accuracy")
                    tmp.setValue(skill.powerPoint, forKey: "powerPoint")
                    tmp.setValue(pokemonCK.recordID.recordName, forKey: "pokemon")
                    
                    skillsCK.append(tmp)
                }
                
                recordsToSavePublic.appendContentsOf(skillsCK)
                recordsToSavePublic.append(statusCK)
                recordsToSavePublic.append(pokemonCK)
            }
            
            let recordsOperation = CKModifyRecordsOperation(recordsToSave: recordsToSavePublic, recordIDsToDelete: nil)
            recordsOperation.savePolicy = .AllKeys
            recordsOperation.modifyRecordsCompletionBlock = { (records: [CKRecord]?, recordsId: [CKRecordID]?, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.addedData(error)
                }
            }
            
            self.container.publicCloudDatabase.addOperation(recordsOperation)
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.addedData(NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: 1, userInfo: [NSLocalizedDescriptionKey: "User is not logged on iCloud."]))
            }
        }
    }
    
    func removePokemon(pokemon: Pokemon, completion: ((error: NSError?) -> Void)?) {
        if let _ = self.userRecord {
            var recordsToDelete: [CKRecordID] = []
            var recordsToDeletePrivate: [CKRecordID] = []
            
            let predicate = NSPredicate(format: "pokemon == %@", pokemon.recordName)
            
            let queryStat = CKQuery(recordType: "Status", predicate: predicate)
            let querySkill = CKQuery(recordType: "Skill", predicate: predicate)
            let queryFav = CKQuery(recordType: "Favorite", predicate: predicate)
            
            self.container.publicCloudDatabase.performQuery(queryStat, inZoneWithID: nil, completionHandler: { (fetchedStats: [CKRecord]?, error: NSError?) -> Void in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion?(error: error)
                    }
                }
                else {
                    self.container.publicCloudDatabase.performQuery(querySkill, inZoneWithID: nil, completionHandler: { (fetchedSkills: [CKRecord]?, error: NSError?) -> Void in
                        if let error = error {
                            dispatch_async(dispatch_get_main_queue()) {
                                completion?(error: error)
                            }
                        }
                        else {
                            self.container.privateCloudDatabase.performQuery(queryFav, inZoneWithID: nil, completionHandler: { (fetchedFavs: [CKRecord]?, error: NSError?) -> Void in
                                if let error = error {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        completion?(error: error)
                                    }
                                }
                                else {
                                    if let fetchedStats = fetchedStats {
                                        for fetchedStat in fetchedStats {
                                            recordsToDelete.append(fetchedStat.recordID)
                                        }
                                    }
                                    if let fetchedSkills = fetchedSkills {
                                        for fetchedSkill in fetchedSkills {
                                            recordsToDelete.append(fetchedSkill.recordID)
                                        }
                                    }
                                    recordsToDelete.append(CKRecordID(recordName: pokemon.recordName))
                                    
                                    if let fetchedFavs = fetchedFavs {
                                        for fetchedFav in fetchedFavs {
                                            recordsToDeletePrivate.append(fetchedFav.recordID)
                                        }
                                    }
                                    
                                    let recordsOperationPrivate = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordsToDeletePrivate)
                                    recordsOperationPrivate.savePolicy = .AllKeys
                                    recordsOperationPrivate.modifyRecordsCompletionBlock = { (records: [CKRecord]?, recordsId: [CKRecordID]?, error: NSError?) -> Void in
                                        if let error = error {
                                            dispatch_async(dispatch_get_main_queue()) {
                                                completion?(error: error)
                                            }
                                        }
                                        else {
                                            let recordsOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordsToDelete)
                                            recordsOperation.savePolicy = .AllKeys
                                            recordsOperation.modifyRecordsCompletionBlock = { (records: [CKRecord]?, recordsId: [CKRecordID]?, error: NSError?) -> Void in
                                                dispatch_async(dispatch_get_main_queue()) {
                                                    completion?(error: error)
                                                }
                                            }
                                            
                                            self.container.publicCloudDatabase.addOperation(recordsOperation)
                                        }
                                    }
                                    
                                    self.container.privateCloudDatabase.addOperation(recordsOperationPrivate)
                                }
                            })
                        }
                    })
                }
            })
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                completion?(error: NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: 1, userInfo: [NSLocalizedDescriptionKey: "User is not logged on iCloud."]))
            }
        }
    }
    
    func favoritePokemon(favorite: Bool, pokemonId: String, completion: ((error: NSError?) -> Void)?) {
        if let _ = self.userRecord {
            if favorite {
                let favorite = CKRecord(recordType: "Favorite")
                favorite.setObject(pokemonId, forKey: "pokemon")
                
                self.container.privateCloudDatabase.saveRecord(favorite, completionHandler: { (record: CKRecord?, error: NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        completion?(error: error)
                    }
                })
            }
            else {
                
                let queryFav = CKQuery(recordType: "Favorite", predicate: NSPredicate(format: "pokemon == %@", pokemonId))
                self.container.privateCloudDatabase.performQuery(queryFav, inZoneWithID: nil, completionHandler: { (records: [CKRecord]?, error: NSError?) -> Void in
                    if let error = error {
                        dispatch_async(dispatch_get_main_queue()) {
                            completion?(error: error)
                        }
                    }
                    else {
                        if let records = records {
                            if records.count > 0 {
                                self.container.privateCloudDatabase.deleteRecordWithID(records[0].recordID, completionHandler: { (recordId: CKRecordID?, error: NSError?) -> Void in
                                    if let error = error {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            completion?(error: error)
                                        }
                                    }
                                    else {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            completion?(error: nil)
                                        }
                                    }
                                })
                            }
                        }
                    }
                })
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                completion?(error: NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: 3, userInfo: nil))
            }
        }
    }
    
    func fetchSkills(completion: (([Skill]?, NSError?) -> Void)?) {
        let querySkills = CKQuery(recordType: "Skill", predicate: NSPredicate(value: true))
        
        self.container.publicCloudDatabase.performQuery(querySkills, inZoneWithID: nil) { (fetchedSkills: [CKRecord]?, errSkills: NSError?) -> Void in
            if let error = errSkills {
                completion?(nil, error)
            }
            else {
                if let fetchedSkills = fetchedSkills {
                    var skills: [Skill] = []
                    for skill in fetchedSkills {
                        skills.append(Skill(name: skill.objectForKey("name") as? String, type: skill.objectForKey("type") as? String, damage: skill.objectForKey("damageCategory") as? String, power: skill.objectForKey("power") as? Int, accuracy: skill.objectForKey("accuracy") as? Int, powerPoint: skill.objectForKey("powerPoint") as? Int))
                    }
                    
                    skills.sortInPlace({ (skill1: Skill, skill2: Skill) -> Bool in
                        return skill1.name < skill2.name
                    })
                    
                    let filtered = skills.filter({ (skill: Skill) -> Bool in
                        var tmp = skills
                        tmp.removeAtIndex(tmp.indexOf(skill)!)
                        for tmp in tmp {
                            if tmp.name == skill.name {
                                skills.removeAtIndex(skills.indexOf(skill)!)
                                return false
                            }
                        }
                        return true
                    })
                    
                    completion?(filtered, nil)
                }
                else {
                    completion?(nil, nil)
                }
            }
        }
    }
    
}
