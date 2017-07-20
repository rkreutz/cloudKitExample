//
//  AddPokemonViewController.swift
//  cloudKitPokemon
//
//  Created by Rodrigo Kreutz on 3/10/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import UIKit
import CloudKit

extension UIView {
    func firstResponder() -> UIView? {
        if self.isFirstResponder() {
            return self
        }
        else {
            for view in self.subviews {
                if let firstResp = view.firstResponder() {
                    return firstResp
                }
            }
        }
        
        return nil
    }
}

class AddPokemonViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var numberTextfield: UITextField!
    @IBOutlet weak var type1Textfield: UITextField!
    @IBOutlet weak var type2Textfield: UITextField!
    @IBOutlet weak var levelTextfield: UITextField!
    @IBOutlet weak var healthTextfield: UITextField!
    @IBOutlet weak var attackTextfield: UITextField!
    @IBOutlet weak var defenseTextfield: UITextField!
    @IBOutlet weak var spAttackTextfield: UITextField!
    @IBOutlet weak var spDefenseTextfield: UITextField!
    @IBOutlet weak var speedTextfield: UITextField!
    @IBOutlet weak var skillsTextfield: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    var imageAsset: CKAsset?
    var iconAsset: CKAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.nameTextfield.delegate = self
        self.numberTextfield.delegate = self
        self.type1Textfield.delegate = self
        self.type2Textfield.delegate = self
        
        self.numberTextfield.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: self.numberTextfield)
        self.levelTextfield.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: self.levelTextfield)
        self.healthTextfield.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: self.healthTextfield)
        self.attackTextfield.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: self.attackTextfield)
        self.defenseTextfield.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: self.defenseTextfield)
        self.spAttackTextfield.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: self.spAttackTextfield)
        self.spDefenseTextfield.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: self.spDefenseTextfield)
        self.speedTextfield.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: self.speedTextfield)
        self.skillsTextfield.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: self.skillsTextfield)
        
        let tapIcon = UITapGestureRecognizer(target: self, action: "chooseIcon:")
        self.icon.userInteractionEnabled = true
        self.icon.addGestureRecognizer(tapIcon)
        
        let tapImage = UITapGestureRecognizer(target: self, action: "chooseImage:")
        self.image.userInteractionEnabled = true
        self.image.addGestureRecognizer(tapImage)
        
        let skillsTable = SkillsTableView(frame: CGRectMake(0, 0, self.view.frame.width, 200), style: .Plain)
        skillsTable.delegate = skillsTable
        skillsTable.dataSource = skillsTable
        skillsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        skillsTable.textfield = self.skillsTextfield
        skillsTable.refreshControl = UIRefreshControl()
        skillsTable.refreshControl.tintColor = UIColor(red: 201/255, green: 0, blue: 0, alpha: 1)
        skillsTable.addSubview(skillsTable.refreshControl)
        skillsTable.addNewSkill = { () -> Void in
            let alert = UIAlertController(title: "Add Skill", message: "Fill all the skill's properties.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler({ (textField: UITextField) -> Void in
                textField.textAlignment = .Center
                textField.autocapitalizationType = .Words
                textField.returnKeyType = .Done
                textField.delegate = self
                textField.placeholder = "Name"
            })
            
            alert.addTextFieldWithConfigurationHandler({ (textField: UITextField) -> Void in
                textField.textAlignment = .Center
                textField.autocapitalizationType = .Words
                textField.returnKeyType = .Done
                textField.delegate = self
                textField.placeholder = "Type"
            })
            
            alert.addTextFieldWithConfigurationHandler({ (textField: UITextField) -> Void in
                textField.textAlignment = .Center
                textField.autocapitalizationType = .Words
                textField.returnKeyType = .Done
                textField.delegate = self
                textField.placeholder = "Damage Category"
            })
            
            alert.addTextFieldWithConfigurationHandler({ (textField: UITextField) -> Void in
                textField.textAlignment = .Center
                textField.autocapitalizationType = .None
                textField.keyboardType = .NumberPad
                textField.placeholder = "Power"
                textField.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: textField)
            })
            
            alert.addTextFieldWithConfigurationHandler({ (textField: UITextField) -> Void in
                textField.textAlignment = .Center
                textField.autocapitalizationType = .None
                textField.keyboardType = .NumberPad
                textField.placeholder = "Accuracy"
                textField.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: textField)
            })
            
            alert.addTextFieldWithConfigurationHandler({ (textField: UITextField) -> Void in
                textField.textAlignment = .Center
                textField.autocapitalizationType = .None
                textField.keyboardType = .NumberPad
                textField.placeholder = "Power Point"
                textField.inputAccessoryView = InputAcessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 50), textField: textField)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            let add = UIAlertAction(title: "Add", style: .Default, handler: { (action: UIAlertAction) -> Void in
                if let name = alert.textFields?[0] {
                    if let type = alert.textFields?[1] {
                        if let damage = alert.textFields?[2] {
                            if let power = alert.textFields?[3] {
                                if let acc = alert.textFields?[4] {
                                    if let pp = alert.textFields?[5] {
                                        let skill = Skill(name: name.text, type: type.text, damage: damage.text, power: Int(power.text!), accuracy: Int(acc.text!), powerPoint: Int(pp.text!))
                                        
                                        (self.skillsTextfield.inputView as! SkillsTableView).values.append(skill)
                                        (self.skillsTextfield.inputView as! SkillsTableView).values.sortInPlace({ (skill1: Skill, skill2: Skill) -> Bool in
                                            return skill1.name < skill2.name
                                        })
                                        (self.skillsTextfield.inputView as! SkillsTableView).selectedIndex.removeAll()
                                        dispatch_async(dispatch_get_main_queue()) {
                                            (self.skillsTextfield.inputView as! SkillsTableView).reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
            
            alert.addAction(cancel)
            alert.addAction(add)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        self.skillsTextfield.inputView = skillsTable
        
        CloudKitModel.sharedInstance.fetchSkills { (records: [Skill]?, error: NSError?) -> Void in
            if let _ = error {
                let alert = UIAlertController(title: "Warning", message: "Something went wrong while trying to fetch skills.", preferredStyle: .Alert)
                
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                alert.addAction(ok)
                
                dispatch_async(dispatch_get_main_queue()) {
                    (self.skillsTextfield.inputView as! SkillsTableView).setContentOffset(CGPointMake(0, 0), animated: true)
                    (self.skillsTextfield.inputView as! SkillsTableView).refreshControl.endRefreshing()
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else {
                if let records = records {
                    (self.skillsTextfield.inputView as! SkillsTableView).values = records
                    dispatch_async(dispatch_get_main_queue()) {
                        (self.skillsTextfield.inputView as! SkillsTableView).setContentOffset(CGPointMake(0, 0), animated: true)
                        (self.skillsTextfield.inputView as! SkillsTableView).refreshControl.endRefreshing()
                        (self.skillsTextfield.inputView as! SkillsTableView).reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                }
                else {
                    let alert = UIAlertController(title: "Warning", message: "Something went wrong while trying to fetch skills.", preferredStyle: .Alert)
                    
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alert.addAction(ok)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        (self.skillsTextfield.inputView as! SkillsTableView).setContentOffset(CGPointMake(0, 0), animated: true)
                        (self.skillsTextfield.inputView as! SkillsTableView).refreshControl.endRefreshing()
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func savePokemon(sender: AnyObject) {
        if self.nameTextfield.hasText() && self.numberTextfield.hasText() && self.type1Textfield.hasText() && self.levelTextfield.hasText() && self.healthTextfield.hasText() && self.attackTextfield.hasText() && self.defenseTextfield.hasText() && self.spAttackTextfield.hasText() && self.spDefenseTextfield.hasText() && self.speedTextfield.hasText() {
            
            let name = self.nameTextfield.text
            let number = Int(self.numberTextfield.text!)
            let type1 = self.type1Textfield.text
            let type2 = (self.type2Textfield.text == "") ? nil : self.type2Textfield.text
            let level = Int(self.levelTextfield.text!)
            let health = Int(self.healthTextfield.text!)!
            let attack = Int(self.attackTextfield.text!)!
            let defense = Int(self.defenseTextfield.text!)!
            let spAttack = Int(self.spAttackTextfield.text!)!
            let spDefense = Int(self.spDefenseTextfield.text!)!
            let speed = Int(self.speedTextfield.text!)!
            let status = NSDictionary(dictionary: ["health": health, "attack": attack, "defense": defense, "spAttack": spAttack, "spDefense": spDefense, "speed": speed])
            let skills = NSMutableArray()
            for skill in (self.skillsTextfield.inputView as! SkillsTableView).selectedSkills() {
                skills.insertObject(NSDictionary(dictionary: ["name": skill.name, "type": skill.type, "damageCategory": skill.damageCategory, "power": skill.power, "accuracy": skill.accuracy, "powerPoint": skill.powerPoint]), atIndex: 0)
            }
            
            let pokemon = Pokemon(number: number, name: name, icon: nil, image: nil, level: level, type: type1, type2: type2, status: status, skills: skills)
            
            if let imageAsset = self.imageAsset {
                pokemon.image = self.image.image
                pokemon.imageAsset = imageAsset
            }
            if let iconAsset = self.iconAsset {
                pokemon.icon = self.icon.image
                pokemon.iconAsset = iconAsset
            }
            
            self.performSegueWithIdentifier("return", sender: pokemon)
        }
        else {
            let alert = UIAlertController(title: "Warning", message: "Only type 2, image, icon and skills are optional.", preferredStyle: .Alert)

            let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)

            alert.addAction(ok)

            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func cancelSave(sender: AnyObject) {
        self.performSegueWithIdentifier("return", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pokemon = sender as? Pokemon {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                CloudKitModel.sharedInstance.addPokemon(pokemon)
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    func keyboardWillShow(notification:NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
            if let responder = self.view.firstResponder() {
                let offset = self.view.frame.height - keyboardFrame.height - (responder.frame.origin.y + responder.frame.height)
                
                if offset < 0 {
                    self.constraint.constant = offset
                    self.view.setNeedsUpdateConstraints()
                    
                    UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    })
                }
            }
            
            if self.skillsTextfield.isFirstResponder() {
                (self.skillsTextfield.inputView as! SkillsTableView).reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
                if (self.skillsTextfield.inputView as! SkillsTableView).values.count == 0 {
                    (self.skillsTextfield.inputView as! SkillsTableView).setContentOffset(CGPointMake(0, -(self.skillsTextfield.inputView as! SkillsTableView).refreshControl.frame.height), animated: true)
                    (self.skillsTextfield.inputView as! SkillsTableView).refreshControl.beginRefreshing()
                }
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        if let userInfo = notification.userInfo {
            let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
            
            self.constraint.constant = 16
            self.view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(animationDurarion) { () -> Void in
                self.view.layoutIfNeeded()
            }
            
            if self.skillsTextfield.isFirstResponder() {
                if (self.skillsTextfield.inputView as! SkillsTableView).values.count == 0 {
                    (self.skillsTextfield.inputView as! SkillsTableView).setContentOffset(CGPointMake(0, 0), animated: true)
                    (self.skillsTextfield.inputView as! SkillsTableView).refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func chooseImage(sender: AnyObject) {
        let picker = ImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = picker
        picker.completion = { (image: UIImage) -> Void in
            let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
            if paths.count > 0 {
                let writePath = paths[0].stringByAppendingString("/temporaryImage.png")
                UIImagePNGRepresentation(image)?.writeToFile(writePath, atomically: true)
                self.imageAsset = CKAsset(fileURL: NSURL.fileURLWithPath(writePath))
                self.image.image = image
            }
        }
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func chooseIcon(sender: AnyObject) {
        let picker = ImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = picker
        picker.completion = { (image: UIImage) -> Void in
            let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
            if paths.count > 0 {
                let writePath = paths[0].stringByAppendingString("/temporaryIcon.png")
                UIImagePNGRepresentation(image)?.writeToFile(writePath, atomically: true)
                self.iconAsset = CKAsset(fileURL: NSURL.fileURLWithPath(writePath))
                self.icon.image = image
            }
        }
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
}
