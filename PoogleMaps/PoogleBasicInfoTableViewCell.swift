//
//  PoogleBasicInfoTableViewCell.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/19/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit

class PoogleBasicInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var reviewNumberLabel: UILabel!
    
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    // Ratings
    @IBOutlet weak var cleanLabel: UILabel!
    @IBOutlet weak var secludedLabel: UILabel!
    @IBOutlet weak var convenientLabel: UILabel!
    @IBOutlet weak var spaciousLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
    }
    
    func setRating (_ rating: Int) {
        star1.image = UIImage(named: "star-empty")
        star2.image = UIImage(named: "star-empty")
        star3.image = UIImage(named: "star-empty")
        star4.image = UIImage(named: "star-empty")
        star5.image = UIImage(named: "star-empty")
        
        if rating >= 1 {
            star1.image = UIImage(named: "star")
            if rating >= 2 {
                star2.image = UIImage(named: "star")
                if rating >= 3 {
                    star3.image = UIImage(named: "star")
                    if rating >= 4 {
                        star4.image = UIImage(named: "star")
                        if rating >= 5 {
                            star5.image = UIImage(named: "star")
                            
                        }
                    }
                }
            }
        }
    }
    
    func setAttributes(_ attr: [String:[Float]]) {
        
        // Average attribute values from all testimonials and update labels
        let cleanArr: [Float] = attr["clean"]! as [Float]
        let cleanAvg: Float = cleanArr.reduce(0, +) / Float(cleanArr.count)
        let cleanRounded: NSString = NSString(format: "%.01f", cleanAvg)
        
        let secludedArr: [Float] = attr["secluded"]! as [Float]
        let secludedAvg: Float = secludedArr.reduce(0, +) / Float(secludedArr.count)
        let secludedRounded: NSString = NSString(format: "%.01f", secludedAvg)
        
        let convenientArr: [Float] = attr["convenient"]! as [Float]
        let convenientAvg: Float = convenientArr.reduce(0, +) / Float(convenientArr.count)
        let convenientRounded: NSString = NSString(format: "%.01f", convenientAvg)
        
        let spaciousArr: [Float] = attr["spacious"]! as [Float]
        let spaciousAvg: Float = spaciousArr.reduce(0, +) / Float(spaciousArr.count)
        let spaciousRounded: NSString = NSString(format: "%.01f", spaciousAvg)
        
        if !cleanAvg.isNaN {
            cleanLabel.text = "\(cleanRounded) / 10"
        }
        if !secludedAvg.isNaN {
            secludedLabel.text = "\(secludedRounded) / 10"
        }
        if !convenientAvg.isNaN {
            convenientLabel.text = "\(convenientRounded) / 10"
        }
        if !spaciousAvg.isNaN {
            spaciousLabel.text = "\(spaciousRounded) / 10"
        }
    }
    
    func setRatingCount(_ count: Int) {
        reviewNumberLabel.text = "(\(count))"
    }
    
    func updateRating(_ ratings: [Float]) {
        // Get average rating and set stars to reflect it
        if ratings.count > 0 {
            var avg: Float = 0.0
            for num in ratings {
                avg += num
            }
            avg /= Float(ratings.count)
            
            setRating(Int(avg))
        }
    }

}
