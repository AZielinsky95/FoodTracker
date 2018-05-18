//
//  MealCell.swift
//  FoodTracker
//
//  Created by Alejandro Zielinsky on 2018-05-18.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

import UIKit

class MealCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var photoImage: UIImageView!
    
    @IBOutlet weak var ratingControl: RatingControl!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
