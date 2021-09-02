//
//  AddARowCell.swift
//  CatalystTestApp
//
//  Created by Umashri R on 11/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import UIKit

class AddRowCell : UITableViewCell
{
    
    static let identifier = "AddARowCell"

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected( _ selected : Bool, animated : Bool )
    {
        super.setSelected( selected, animated : animated )
        // Configure the view for the selected state
    }
    
    static func dequeue( _ tableView : UITableView, indexPath : IndexPath, title : String ) -> AddRowCell
    {
        let cell = tableView.dequeueReusableCell( withIdentifier : <#T##String#>, for: <#T##IndexPath#>)
    }

}
