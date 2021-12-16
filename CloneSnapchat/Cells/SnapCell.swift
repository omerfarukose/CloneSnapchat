//
//  SnapCell.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 14.12.2021.
//

import UIKit

class SnapCell: UITableViewCell {
    
    
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var openImage: UIImageView!
    @IBOutlet weak var bitmoImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
