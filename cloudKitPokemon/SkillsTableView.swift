//
//  SkillsTableView.swift
//  cloudKitPokemon
//
//  Created by Rodrigo Kreutz on 3/11/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import UIKit
import CloudKit

class SkillsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var selectedIndex = Set<NSIndexPath>()
    var values: [Skill] = []
    weak var textfield: UITextField!
    var refreshControl: UIRefreshControl!
    var addNewSkill: (() -> Void)?
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        if indexPath.row < self.values.count {
            cell.textLabel?.text = self.values[indexPath.row].name
        }
        else {
            cell.textLabel?.text = "Add"
        }
        
        if self.selectedIndex.contains(indexPath) && indexPath.row < self.values.count {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        cell.tintColor = UIColor(red: 201/255, green: 0, blue: 0, alpha: 1)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count + 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row < self.values.count {
            if self.selectedIndex.contains(indexPath) {
                self.selectedIndex.remove(indexPath)
            }
            else {
                self.selectedIndex.insert(indexPath)
            }
            
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            self.textfield.text = self.selectedValues()
        }
        else {
            self.addNewSkill?()
        }
    }
    
    func selectedValues() -> String {
        var str = ""
        for i in self.selectedIndex {
            if str == "" {
                str += self.values[i.row].name
            }
            else {
                str += ", \(self.values[i.row].name)"
            }
        }
        
        return str
    }
    
    func selectedSkills() -> [Skill] {
        var skills: [Skill] = []
        for i in self.selectedIndex {
            skills.append(self.values[i.row])
        }
        return skills
    }

}
