//
//  IconPickerController.swift
//  cloudKitPokemon
//
//  Created by Rodrigo Kreutz on 3/10/16.
//  Copyright © 2016 Rodrigo Kreutz. All rights reserved.
//

import UIKit

class IconPickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var completion: (UIImage -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        var newImage: UIImage!
        
        if image.size.width > 32.0 || image.size.height > 32.0 {
            var newSize: CGSize!
            if image.size.width > image.size.height {
                newSize = CGSizeMake(32.0 , image.size.height * 32.0/image.size.width)
            }
            else {
                newSize = CGSizeMake(image.size.width * 32.0/image.size.height, 32.0)
            }
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        else {
            newImage = image
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.completion?(newImage)
        }
    }
    
}
