//
//  Custom_Cell.swift
//  Messenger
//
//  Created by Field Employee on 11/14/20.
//

import UIKit

class Custom_Cell: UITableViewCell {


    @IBOutlet weak var name_outlet: UILabel!
    
    @IBOutlet weak var user_email_outlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBOutlet weak var image_outlet: UIImageView!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
