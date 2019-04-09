//
//  ItemViewCell.swift
//  CoreDataSample
//
//  Created by Easyway_Mac2 on 09/04/19.
//  Copyright © 2019 Easyway_Mac2. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemId: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
