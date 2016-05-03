//
//  TestimonialTableViewCell.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/19/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit

class TestimonialTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
