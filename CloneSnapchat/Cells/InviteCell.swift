//
//  InviteCell.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 14.12.2021.
//

import UIKit

class InviteCell: UITableViewCell {

    @IBOutlet weak var bitmoImage: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var ignoreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
