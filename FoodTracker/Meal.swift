//
//  Meal.swift
//  FoodTracker
//
//  Created by Alejandro Zielinsky on 2018-05-18.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

import Foundation
import UIKit
import os.log

class Meal : NSObject {

    var name: String
    var mealDescription : String
    var calories: Int
    var photo: UIImage?
    var photoURL : String?
    var rating: Int?
    var mealID: String? = nil;
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    convenience init?(dict:[String:Any])
    {
        let title = dict["title"] as! String
        let calories = dict["calories"] as! Int
        let desc = dict["description"] as! String
        let rating = dict["rating"] as? Int
        let imageURL = dict["imagePath"] as? String
        
        self.init(name: title,photo:nil,photoURLString: imageURL, rating: rating, calories: calories, description: desc)
    }
//
//    if let url = imageURL
//        {
//            RequestController.downloadImage(url: url as! URL) { [weak self] (image) in
//
//                if let p = image
//                {
//                    mealPhoto = p
//                }
//            }
//    }
    
    init?(name: String,photo: UIImage?,photoURLString: String?, rating: Int?,calories:Int,description:String)
    {
        
        guard !name.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
       if let r = rating
       {
            guard (r >= 0) && (r <= 5) else {
                return nil
            }
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.photoURL = photoURLString;
        self.rating = rating
        self.mealDescription = description;
        self.calories = calories;
    }
    
    
}
