//
//  ComicCell.swift
//  task
//
//  Created by Harun Cem DERE on 24.10.2021.
//

import UIKit

class ComicCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(with name: String) {
        lblName.text = name
    }
    
}
