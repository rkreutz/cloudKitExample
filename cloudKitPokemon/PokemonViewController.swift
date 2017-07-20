//
//  PokemonViewController.swift
//  webServerPokemon
//
//  Created by Rodrigo Kreutz on 3/1/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import UIKit

class PokemonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var pokemon: Pokemon!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favorite: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.image.image = self.pokemon.image
        self.name.text = self.pokemon.name
        self.number.text = "(nº \(self.pokemon.number))"
        self.level.text = "Lvl \(self.pokemon.level)"
        if let type2 = self.pokemon.type2 {
            type.text = "\(self.pokemon.type) / \(type2)"
        }
        else {
            type.text = "\(self.pokemon.type)"
        }
        
        if pokemon.favorite {
            self.favorite.image = UIImage(named: "fav")
        }
        
        let tap = UITapGestureRecognizer(target: self, action: "tapFavorite:")
        self.favorite.addGestureRecognizer(tap)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if section == 0 {
            title = "Status"
        }
        else {
            title = "Skills"
        }
        return title
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("statsCell")!
            
            cell.selectionStyle = .None
            
            let attr = cell.viewWithTag(1) as! UILabel
            let value = cell.viewWithTag(2) as! UILabel
            
            switch indexPath.row {
            case 1:
                attr.text = "Attack"
                value.text = "\(self.pokemon.status.attack)"
                break
            case 2:
                attr.text = "Defense"
                value.text = "\(self.pokemon.status.defense)"
                break
            case 3:
                attr.text = "Sp. Attack"
                value.text = "\(self.pokemon.status.spAttack)"
                break
            case 4:
                attr.text = "Sp. Defense"
                value.text = "\(self.pokemon.status.spDefense)"
                break
            case 5:
                attr.text = "Speed"
                value.text = "\(self.pokemon.status.speed)"
                break
            default:
                attr.text = "Health"
                value.text = "\(self.pokemon.status.health)"
                break
            }
            
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("skillsCell")!
            
            cell.selectionStyle = .None
            
            let name = cell.viewWithTag(1) as! UILabel
            name.text = self.pokemon.skills[indexPath.row].name
            
            let type = cell.viewWithTag(2) as! UILabel
            type.text = self.pokemon.skills[indexPath.row].type
            
            let cat = cell.viewWithTag(3) as! UILabel
            cat.text = self.pokemon.skills[indexPath.row].damageCategory
            
            let pow = cell.viewWithTag(4) as! UILabel
            pow.text = "\(self.pokemon.skills[indexPath.row].power)"
            
            let acc = cell.viewWithTag(5) as! UILabel
            acc.text = "\(self.pokemon.skills[indexPath.row].accuracy)"
            
            let pp = cell.viewWithTag(6) as! UILabel
            pp.text = "\(self.pokemon.skills[indexPath.row].powerPoint)"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if section == 0 {
            rows = 6
        }
        else {
            rows = self.pokemon.skills.count
        }
        
        return rows
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = 0
        if indexPath.section == 0 {
            height = 44
        }
        else {
            height = 100
        }
        
        return CGFloat(height)
    }
    
    func tapFavorite(sender: AnyObject) {
        self.pokemon.favorite = !self.pokemon.favorite
        
        self.view.userInteractionEnabled = false
        
        CloudKitModel.sharedInstance.favoritePokemon(self.pokemon.favorite, pokemonId: self.pokemon.recordName) { (error: NSError?) -> Void in
            self.view.userInteractionEnabled = true
            
            if let error = error {
                let alert = UIAlertController(title: "Warning", message: "An error occured while trying to favorite a pokemon to the database.", preferredStyle: .Alert)
                
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                alert.addAction(ok)
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                print(error)
            }
            else {
                if !self.pokemon.favorite {
                    self.favorite.image = UIImage(named: "notFav")
                }
                else {
                    self.favorite.image = UIImage(named: "fav")
                }
            }
        }
    }

}
