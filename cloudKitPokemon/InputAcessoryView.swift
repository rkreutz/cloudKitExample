//
//  InputAcessoryView.swift
//  MyTrainer
//
//  Created by Rodrigo Kreutz on 11/11/15.
//  Copyright © 2015 noNamed. All rights reserved.
//

import UIKit

class InputAcessoryView: UIView {
    
    weak var textField: UITextField!
    
    init(frame: CGRect, textField: UITextField!) {
        super.init(frame: frame)
        
        self.textField = textField
        
        let cancel = UIButton(frame: CGRectMake(0,0,100,50))
        let done = UIButton(frame: CGRectMake(frame.width - 100, 0, 100, 50))
        cancel.setTitle("Cancel".localized, forState: .Normal)
        cancel.contentHorizontalAlignment = .Left
        cancel.contentVerticalAlignment = .Center
        cancel.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0)
        cancel.setTitleColor(UIColor(red: 255/255, green: 54/255, blue: 168/255, alpha: 1), forState: UIControlState.Normal)
        cancel.titleLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 14)
        cancel.titleLabel?.adjustsFontSizeToFitWidth = true
        cancel.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchUpInside)
        done.setTitle("Done".localized, forState: .Normal)
        done.contentHorizontalAlignment = .Right
        done.contentVerticalAlignment = .Center
        done.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 16)
        done.setTitleColor(UIColor(red: 102/255, green: 130/255, blue: 152/255, alpha: 1), forState: UIControlState.Normal)
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
        
        self.textField.endEditing(true)
    }

}
