//
//  PersonCell.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 15.12.2021.
//

import UIKit

class PersonCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var circleImage: UIImageView!
    
    var personSelected = false
    var selectedName = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleImage.isUserInteractionEnabled = true
        let imageGRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectCircle))
        circleImage?.addGestureRecognizer(imageGRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func selectCircle(){
        
        if personSelected == false {
            personSelected = true
            circleImage?.image = UIImage(named: "okloko")
            SelectedModel.sharedInstance.selectedFriends.append(selectedName)
        } else {
            var selectedNames = SelectedModel.sharedInstance.selectedFriends
            personSelected = false
            circleImage?.image = UIImage(named: "addlogo")
            for i in 0...(selectedNames.count - 1) {
                if selectedNames[i] == selectedName {
                    selectedNames.remove(at: i)
                    break
                }
            }
            SelectedModel.sharedInstance.selectedFriends = selectedNames
        }
    }

    
    
}
