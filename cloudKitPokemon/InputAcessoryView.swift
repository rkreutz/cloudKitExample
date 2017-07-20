//
//  InputAcessoryView.swift
//  MyTrainer
//
//  Created by Rodrigo Kreutz on 11/11/15.
//  Copyright © 2015 noNamed. All rights reserved.
//

import UIKit

func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
}

class InputAcessoryView: UIView {
    
    weak var textField: UITextField!
    
    init(frame: CGRect, textField: UITextField!) {
        super.init(frame: frame)
        
        self.textField = textField
        
        let cancel = UIButton(frame: CGRectMake(0,0,100,50))
        let done = UIButton(frame: CGRectMake(frame.width - 100, 0, 100, 50))
        cancel.setTitle("Cancel", forState: .Normal)
        cancel.contentHorizontalAlignment = .Left
        cancel.contentVerticalAlignment = .Center
        cancel.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0)
        cancel.setTitleColor(UIColor(red: 201/255, green: 0, blue: 0, alpha: 1), forState: UIControlState.Normal)
        cancel.titleLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 14)
        cancel.titleLabel?.adjustsFontSizeToFitWidth = true
        cancel.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchUpInside)
        done.setTitle("Done", forState: .Normal)
        done.contentHorizontalAlignment = .Right
        done.contentVerticalAlignment = .Center
        done.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 16)
        done.setTitleColor(UIColor(red: 201/255, green: 0, blue: 0, alpha: 1), forState: UIControlState.Normal)
        done.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        done.titleLabel?.adjustsFontSizeToFitWidth = true
        done.addTarget(self, action: "done:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(done)
        self.addSubview(cancel)
        self.clipsToBounds = true
        self.backgroundColor = UIColorFromHex(0xEFEFF4)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func done(sender: AnyObject?) {
        self.textField.endEditing(true)
    }
    
    @IBAction func cancel(sender: AnyObject?) {
        self.textField.text = ""
        
        if let table = self.textField.inputView as? SkillsTableView {
            table.selectedIndex.removeAll()
        }
        
        self.textField.endEditing(true)
    }

}
