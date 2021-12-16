//
//  RankCell.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 16.12.2021.
//

import UIKit

class RankCell: UITableViewCell {

    @IBOutlet weak var userIndexLabel: UILabel!
    @IBOutlet weak var userBitmoImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userScoreLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
