//
//  CharacterCell.swift
//  task
//
//  Created by Harun Cem DERE on 22.10.2021.
//

import UIKit
import ImageLoader

class CharacterCell: UITableViewCell {

    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(character: CharacterViewModel) {
        self.selectionStyle = .none
        self.lblName?.text = character.name
        if let path = character.getImageUrl(){
            if let url = URL(string: path){
                self.ivPhoto.load.request(with: url)
            }
        }
    }

}

