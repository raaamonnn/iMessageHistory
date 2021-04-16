//
//  TVCText.swift
//  iMessageHistory
//
//  Created by Ramon Amini on 4/3/21.
//

import UIKit

class TVCText: UITableViewCell {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var isUser: UIImageView!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)

        // Configure the view for the selected state
    }
    
}
