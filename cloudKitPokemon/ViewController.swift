//
//  ViewController.swift
//  cloudKitPokemon
//
//  Created by Rodrigo Kreutz on 3/8/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CloudKitModelDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pokemons: [Pokemon]! = []
    
    let refreshControl = UIRefreshControl()
    let container = CKContainer.defaultContainer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.refreshControl.tintColor = UIColor(red: 201.0/255.0, green: 0, blue: 0, alpha: 1.0)
        
        self.refreshControl.addTarget(CloudKitModel.sharedInstance, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        CloudKitModel.sharedInstance.delegate = self
        
        CloudKitModel.sharedInstance.checkICloudCredentials(self.container)
        
        self.startRefreshing(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
    
    func startRefreshing(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.setContentOffset(CGPointMake(0, -self.refreshControl.frame.height), animated: true)
            self.refreshControl.beginRefreshing()
        }
    }
    
    func endRefreshing(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.setContentOffset(CGPointMake(0, 0), animated: true)
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pokemonCell")!
        
        let pokemon = self.pokemons[indexPath.row]
        
        let icon = cell.viewWithTag(1) as! UIImageView
        icon.image = pokemon.icon
        
        let name = cell.viewWithTag(2) as! UILabel
        name.text = pokemon.name
        
        let number = cell.viewWithTag(3) as! UILabel
        number.text = "(nº \(pokemon.number))"
        
        let level = cell.viewWithTag(4) as! UILabel
        level.text = "Lvl \(pokemon.level)"
        
        let type = cell.viewWithTag(5) as! UILabel
        if let type2 = pokemon.type2 {
            type.text = "\(pokemon.type) / \(type2)"
        }
        else {
            type.text = "\(pokemon.type)"
        }
        
        let fav = cell.viewWithTag(6) as! UIImageView
        if pokemon.favorite {
            fav.image = UIImage(named: "fav")
        }
        else {
            fav.image = UIImage(named: "notFav")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pokemons.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("showPokemon", sender: indexPath.row)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.tableView.userInteractionEnabled = false
            
            self.startRefreshing(self)
            
            CloudKitModel.sharedInstance.removePokemon(self.pokemons[indexPath.row], completion: { (error: NSError?) -> Void in
                if let error = error {
                    let alert = UIAlertController(title: "Warning", message: "An error occured while trying to remove a pokemon to the database.", preferredStyle: .Alert)
                    
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alert.addAction(ok)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    print(error)
                }
                else {
                    self.pokemons.removeAtIndex(indexPath.row)
                    
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                
                self.endRefreshing(self)
                self.tableView.userInteractionEnabled = true
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPokemon" {
            if let number = sender as? Int {
                let dst = segue.destinationViewController as! PokemonViewController
                
                dst.pokemon = self.pokemons[number]
            }
        }
    }
    
    func addArrayOfPokemons(array: NSArray) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            var pokemons: [Pokemon] = []
            for dictionary in array {
                if let dictionary = dictionary as? NSDictionary {
                    let pokemon = Pokemon(number: dictionary.objectForKey("number") as? Int, name: dictionary.objectForKey("name") as? String, icon: dictionary.objectForKey("icon") as? String, image: dictionary.objectForKey("image") as? String, level: dictionary.objectForKey("level") as? Int, type: dictionary.objectForKey("type1") as? String, type2: dictionary.objectForKey("type2") as? String, status: dictionary.objectForKey("status") as? NSDictionary, skills: dictionary.objectForKey("skills") as? NSArray)
                    
                    pokemons.append(pokemon)
                }
            }
            
            CloudKitModel.sharedInstance.addMultiplePokemons(pokemons)
        }
    }
    
    func addJSON() {
        if let path = NSBundle.mainBundle().pathForResource("pokemons", ofType: "json") {
            var jsonData: NSData!
            do {
                jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            }
            catch _ {
                let alert = UIAlertController(title: "Warning", message: "An error occured while reading JSON file.", preferredStyle: .Alert)
                
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                alert.addAction(ok)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            do {
                if let jsonResul = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSArray {
                    self.addArrayOfPokemons(jsonResul)
                }
                else {
                    let alert = UIAlertController(title: "Warning", message: "An error occured while reading JSON file.", preferredStyle: .Alert)
                    
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alert.addAction(ok)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
            catch _ {
                let alert = UIAlertController(title: "Warning", message: "An error occured while reading JSON file.", preferredStyle: .Alert)
                
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                alert.addAction(ok)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func addPokemon(sender: AnyObject) {
        if let _ = CloudKitModel.sharedInstance.userRecord {
            self.performSegueWithIdentifier("addPokemon", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Warning", message: "You must be logged on iCloud to add a pokemon, please pull the table to refresh your information.", preferredStyle: .Alert)
            
            let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alert.addAction(ok)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func logStatus(error: NSError?) {
        if let error = error {
            print(error)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.endRefreshing(self)
                
                let alert = UIAlertController(title: "Warning", message: "To add/remove a pokemon you must be logged on iCloud and have internet connection.", preferredStyle: .Alert)
                
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                alert.addAction(ok)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            CloudKitModel.sharedInstance.refreshData(self)
        }
    }
    
    func refreshData(pokemons: [Pokemon]?, withError error: NSError?) {
        if let error = error {
            let alert = UIAlertController(title: "Warning", message: "An error occured while trying to download database, please try again later.", preferredStyle: .Alert)
            
            let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alert.addAction(ok)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            
                self.endRefreshing(self)
            }
            
            print(error)
        }
        else {
            if let pokemons = pokemons {
                if pokemons.count > 0 {
                    self.pokemons = pokemons.sort( { (first: Pokemon, second: Pokemon) -> Bool in
                        return first.number < second.number
                    } )
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.endRefreshing(self)
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                }
                else {
                    self.pokemons = []
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.endRefreshing(self)
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
                        
                        let alert = UIAlertController(title: "Warning", message: "Database is empty, we'll add some pokemons right now.", preferredStyle: .Alert)
                        
                        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                            self.startRefreshing(self)
                            self.addJSON()
                        })
                        
                        alert.addAction(ok)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                self.pokemons = []
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.endRefreshing(self)
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                    let alert = UIAlertController(title: "Warning", message: "Database is empty, we'll add some pokemons right now.", preferredStyle: .Alert)
                    
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                        self.startRefreshing(self)
                        self.addJSON()
                    })
                    
                    alert.addAction(ok)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func addedData(withError: NSError?) {
        if let error = withError {
            if error.code == 1 {
                let alert = UIAlertController(title: "Warning", message: "You must be logged to add a pokemon.", preferredStyle: .Alert)
                
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                alert.addAction(ok)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    self.endRefreshing(self)
                }
            }
            else {
                let alert = UIAlertController(title: "Warning", message: "An error occured while trying to add a pokemon to the database.", preferredStyle: .Alert)
                
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                alert.addAction(ok)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
            
                    print(error)
                    
                    self.endRefreshing(self)
                }
            }
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * Int64(NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                CloudKitModel.sharedInstance.refreshData(self)
            }
        }
    }
    
    @IBAction func addPokemonRewind(segue: UIStoryboardSegue) {
        self.startRefreshing(self)
    }
}

