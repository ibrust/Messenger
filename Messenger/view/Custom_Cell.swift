//
//  Custom_Cell.swift
//  Messenger
//
//  Created by Field Employee on 11/14/20.
//

import UIKit

class Custom_Cell: UITableViewCell {

    @IBOutlet weak var user_email_outlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
